import Foundation
import CoreData
import Promises

class CoreDataSource<T: NSManagedObject, U: Identifiable & Codable>: DataSource<U> {
    private let context: NSManagedObjectContext = CoreDataStack.persistentStorage().persistentContainer.viewContext
    
    override func origin() -> Origin {
        return .local
    }
    
    @discardableResult override func add(_ obj: U) -> Result {
        do {
            let _ : T = managedObject(from : obj, inContext: context)
            try context.save()
            return .success
        } catch {
            return .error(error)
        }
    }
    
    @discardableResult override func delete(_ obj : U) -> Result {
        do {
            let moObj : T = managedObject(from : obj, inContext: context)
            context.delete(moObj)
            try context.save()
            return Result.success
        } catch {
            return Result.error(error)
        }
    }
    
    @discardableResult override func delete(_ objects : [U]) -> Result {
        do {
            for obj in objects {
                let moObj : T = managedObject(from : obj, inContext: context)
                context.delete(moObj)
            }
            try context.save()
            return Result.success
        } catch {
            return Result.error(error)
        }
    }
    
    @discardableResult override func clearAll() -> Result {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: T.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            return Result.success
        }
        catch {
            return Result.error(error)
        }
    }
    
    @discardableResult override func update(_ obj : U) -> Result {
        delete(obj)
        return self.add(obj)
        
    }
    override func list() -> [U] {
        let all : [T] = T.all(in: context)
        return all.map({$0.convert()})
    }
    
    override func load() -> Promise<[U]> {
        return Promise<[U]> {resolve,reject in  resolve(self.list())}
    }
    
    
    private func managedObject<T: NSManagedObject>(from : U, inContext context: NSManagedObjectContext) -> T {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName)
        request.predicate = NSPredicate(format: "id == %@", from.id)
        if let objects: [T] = try? context.fetch(request), let result = objects.first {
            return result
        }
        
        let className = String(describing: T.self).components(separatedBy: ".").last ?? String(describing: T.self)
        let moObject = NSEntityDescription.insertNewObject(forEntityName: className, into: context)
        
        let fromMirror = Mirror(reflecting: from)
        for (name, propertyValue) in fromMirror.children {
            guard let propertyName = name else { continue }
            if let propObj = propertyValue as? Identifiable & Codable {
                if let nestedObject = relationshipObject(for: moObject, propertyName: propertyName, object: propObj){
                    moObject.setValue(nestedObject, forKey: propertyName)
                }
            }
            else if let propObjs = propertyValue as? [Identifiable & Codable] {
                var nestedObjects = Set<NSManagedObject>()
                for propObj in propObjs {
                    if  let nestedObject = relationshipObject(for: moObject, propertyName: propertyName, object: propObj) {
                        nestedObjects.insert(nestedObject)
                    }
                }
                if nestedObjects.count > 0 {
                    moObject.setValue(nestedObjects, forKey: propertyName)
                }
            }
            else {
                if Mirror(reflecting: propertyValue).displayStyle == Mirror.DisplayStyle.enum {
                    moObject.setValue(String(describing: propertyValue), forKey: propertyName)
                } else if Mirror(reflecting: propertyValue).displayStyle == Mirror.DisplayStyle.dictionary {
                    moObject.setValue(NSKeyedArchiver.archivedData(withRootObject: propertyValue), forKey: propertyName)
                } else if moObject.entity.propertiesByName.keys.contains(propertyName) {
                    moObject.setValue(propertyValue, forKey: propertyName)
                }
            }
            
        }
        
        guard let resultObject = moObject as? T else { fatalError("Managed Object has unexpected type") }
        return resultObject
    }
    
    private func fetchOrCreate<T:NSManagedObject>(type : AnyClass, obj : Identifiable) -> T {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName)
        request.predicate = NSPredicate(format: "id == %@", obj.id)
        if let objects: [T] = try? context.fetch(request), let result = objects.first {
            return result
        }
        
        let className = String(describing: T.self).components(separatedBy: ".").last ?? String(describing: T.self)
        let moObject = NSEntityDescription.insertNewObject(forEntityName: className, into: context)
        
        return moObject as! T
    }
    
    private func relationshipObject(for moObject: NSManagedObject,
                                    propertyName: String,
                                    object: Identifiable & Codable) -> NSManagedObject? {
        guard let relationEntityName =  moObject.entity.relationshipsByName[propertyName]?.destinationEntity?.name else { return nil }
        
        // get an existing object or create new one
        let nestedObj: NSManagedObject
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: relationEntityName)
        request.predicate = NSPredicate(format: "id == %@", object.id)
        if let objects: [NSManagedObject] = try? context.fetch(request), let result = objects.first {
            nestedObj = result
        }
        else {
            nestedObj = NSEntityDescription.insertNewObject(forEntityName: relationEntityName, into: context)
        }
        
        // go thru the properties
        let fromMirror = Mirror(reflecting: object)
        for (name, propertyValue) in fromMirror.children {
            guard let propertyName = name else { return nil }
            if let propObjs = propertyValue as? [Identifiable & Codable] {
                var subNestedObjects = Set<NSManagedObject>()
                for propObj in propObjs {
                    if let subNestedObject = relationshipObject(for: nestedObj, propertyName: propertyName, object: propObj) {
                        subNestedObjects.insert(subNestedObject)
                    }
                }
                if subNestedObjects.count > 0 {
                    nestedObj.setValue(subNestedObjects, forKey: propertyName)
                }
            } else if let propObj = propertyValue as? Identifiable & Codable {
                if let subNestedObject = relationshipObject(for: nestedObj, propertyName: propertyName, object: propObj){
                    nestedObj.setValue(subNestedObject, forKey: propertyName)
                }
            } else if Mirror(reflecting: propertyValue).displayStyle == Mirror.DisplayStyle.enum {
                nestedObj.setValue(String(describing: propertyValue), forKey: propertyName)
            } else if Mirror(reflecting: propertyValue).displayStyle == Mirror.DisplayStyle.dictionary {
                nestedObj.setValue(NSKeyedArchiver.archivedData(withRootObject: propertyValue), forKey: propertyName)
            } else {
                nestedObj.setValue(propertyValue, forKey: propertyName)
            }
        }
        
        return nestedObj
    }
}

