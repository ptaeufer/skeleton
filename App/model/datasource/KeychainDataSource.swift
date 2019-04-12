import Foundation
import SwiftKeychainWrapper
import Promises


class KeychainDataSource<T:Identifiable & Codable>: DataSource<T> {
    
    private lazy var keychain = self.serviceName != nil ? KeychainWrapper(serviceName: self.serviceName!) : KeychainWrapper.standard
    private let serviceName : String?
    
    
    private var data : [String:String] {
        get {
            if let data = keychain.data(forKey: String(describing: T.self), withAccessibility: .afterFirstUnlock),
                let _data = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : String] {
                return _data
            }
            return [:]
        }
        
        set {
            keychain.set(try! JSONSerialization.data(withJSONObject: newValue, options: []), forKey: String(describing: T.self), withAccessibility: .afterFirstUnlock)
        }
    }
    
    override func origin() -> Origin {
        return .local
    }
    
    init(_ serviceName : String? = nil) {
        self.serviceName = serviceName
    }
    
    @discardableResult override func add(_ obj: T) -> Result {
        do {
            data = data.add(String(data: try CustomJSONEncoder().encode(obj), encoding: .utf8)!, forKey: obj.id)
            return .success
        } catch {
            return .error(error)
        }
        
    }
    
    
    @discardableResult override func delete(_ obj: T) -> Result {
        data = data.filter({$0.key != obj.id})
        return .success
    }
    
    @discardableResult override func delete(_ objects : [T]) -> Result {
        let ids = objects.map{ $0.id }
        data = data.filter{ !ids.contains($0.key )}
        return .success
    }
    
    @discardableResult override func clearAll() -> Result {
        let result = keychain.removeAllKeys()
        return result ? .success : .error(KeychainError.clearAllError)
    }
    
    @discardableResult override func update(_ obj: T) -> Result {
        return self.add(obj)
    }
    
    override func list() -> [T] {
        let decoder = CustomJSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        do {
            return try data.compactMap({try CustomJSONDecoder().decode(T.self, from: $0.value.data(using: .utf8)!)})
        } catch {
            decoder.dateDecodingStrategy = .iso8601
            return data.compactMap({try? CustomJSONDecoder().decode(T.self, from: $0.value.data(using: .utf8)!)})
        }
        
    }
    
    override func load() -> Promise<[T]> {
        return Promise<[T]> { resolve, reject in
            resolve(self.list())
        }
    }
}

extension KeychainDataSource {
    enum KeychainError: Error {
        case clearAllError
    }
}
