import Foundation
import Promises

extension Promise {
    
    @discardableResult
    func then(_ work : @escaping (Value) throws -> Void) -> Promise<Value> {
        return self.then(on: DispatchQueue.main, work)
    }
    
    @discardableResult
    func ´catch´(_ reject : @escaping (Error) -> Void) -> Promise<Value> {
        return self.catch(on: DispatchQueue.main, reject)
    }
}
