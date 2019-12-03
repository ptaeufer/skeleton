

import Foundation
import CoreData

extension NSManagedObject {
    static var entityName: String {
        return String(describing: self)
    }
    
    static func all<T: NSFetchRequestResult>(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) -> [T] {
        var result = [T]()
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        
        context.performAndWait {
            let objects = try? context.fetch(request)
            result = objects ?? []
        }
        return result
    }
    
    static func first<T: NSManagedObject>(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) -> T? {
        let objects: [T] = all(in: context, matching: predicate)
        return objects.first
    }
}


extension NSManagedObject {
    
    
    private func isBoolNumber(_ num:NSNumber) -> Bool
    {
        let boolID = CFBooleanGetTypeID() // the type ID of CFBoolean
        let numID = CFGetTypeID(num) // the type ID of num
        return numID == boolID
    }
    
    func convert<T: Codable>() -> T {
        var keyValues = extractPrimitiveValues(from: self)
        let relationshipsKeyValues = extractRelationships(from: self)
        relationshipsKeyValues.forEach { keyValues[$0] = $1 }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: keyValues, options: [])
            let decoder = CustomJSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            do {
                return try decoder.decode(T.self, from: jsonData)
            } catch {
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: jsonData)
            }
        }
        catch {
            Log.error("error parsing \(String(describing:T.self))", object: error)
            fatalError(error.localizedDescription)
        }
    }
    
    private func extractPrimitiveValues(from object: NSManagedObject) -> [String: Any?] {
        var keyValues = [String: Any?]()
        if object.entity.attributesByName.filter({ $0.key == "json" }).first != nil, let value = object.value(forKey: "json"), let json = NSKeyedUnarchiver.unarchiveObject(with: value as! Data) as? [String: Any?] {
            keyValues = json
        } else {
            for (key, _) in object.entity.attributesByName {
                let value = object.value(forKey: key)
                if let attribute = object.entity.attributesByName[key],
                    attribute.attributeType == .booleanAttributeType {
                    keyValues[key] = (value == nil) ? false : value as! Bool
                } else if value is Int {
                    keyValues[key] = value as! Int
                } else if value is Data {
                    keyValues[key] = NSKeyedUnarchiver.unarchiveObject(with: value as! Data)
                }else if value is Date {
                    keyValues[key] = ISO8601DateFormatter().string(from: value as! Date)
                }else if let attribute = object.entity.attributesByName[key],
                    attribute.attributeType == .stringAttributeType {
                    keyValues[key] = value ?? ""
                } else  {
                    keyValues[key] = value
                }
            }
        }
        
        return keyValues
    }
    
    func extractRelationships(from object: NSManagedObject, originalRelationship: NSRelationshipDescription? = nil) -> [String: Any?] {
        var keyValues = [String: Any?]()
        for (key, rel) in object.entity.relationshipsByName {
            
            if rel.inverseRelationship == originalRelationship {
                // skip inverse relationships to avoid endless recursion
                continue
            }

            let value = object.value(forKey: key)
            if let relatedMO = value as? NSManagedObject {
                var relationData = extractPrimitiveValues(from: relatedMO)
                let relationshipsKeyValues = extractRelationships(from: relatedMO, originalRelationship: rel)
                relationshipsKeyValues.forEach { relationData[$0] = $1 }
                keyValues[key] = relationData
            }
            else if let relatedMOs = value as? Set<NSManagedObject> {
                var relationDatas = [[String: Any?]]()
                for rmo in relatedMOs {
                    var relationData = extractPrimitiveValues(from: rmo)
                    let relationshipsKeyValues = extractRelationships(from: rmo, originalRelationship: rel)
                    relationshipsKeyValues.forEach { relationData[$0] = $1 }
                    relationDatas.append(relationData)
                }
                keyValues[key] = relationDatas
            }
            else if value == nil {
                keyValues[key] = []
            }
        }
        return keyValues
    }
}
