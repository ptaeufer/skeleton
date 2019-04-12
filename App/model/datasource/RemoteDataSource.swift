import Foundation
import Alamofire
import Promises

class RemoteDataSource<U: Identifiable & Codable> : AsyncDataSource<U> {
    
    let api : API
    let service : NetworkingService = inject()
    var dataItems: [U] = []
    
    override func origin() -> Origin {
        return .remote
    }
    
    init(api : API) {
        self.api = api
    }
    
    @discardableResult override func add(_ obj: U) -> Result {
        let _ : Promise<Result> = self.add(obj)
        return .success
    }

    override func add(_ obj: U) -> Promise<Result> {
        return Promise<Result> { resolve, reject in
            do {
                var req = Request(url: self.api.url, method: .post, headers: self.api.headers, params: try obj.dictionary(), interceptor: self.api.interceptor)
                self.service.send(&req).then { response in
                        if self.api.accepts.contains(response.status) || response.error == nil { resolve(.success)}
                        else if let error = response.error{ reject(error) }
                    }.catch(reject)
            } catch { reject(error) }
        }
    }
    
    @discardableResult override func delete(_ obj : U) -> Result  {
        let _ : Promise<Result> = self.delete(obj)
        return .success
    }
    
    override func delete(_ obj: U) -> Promise<DataSource<U>.Result> {
        return Promise<Result> { resolve, reject in
            do {
                var req = Request(url: self.api.url, method: .delete, headers: self.api.headers, params: try obj.dictionary(), interceptor: self.api.interceptor)
                self.service.send(&req).then { response in
                    if self.api.accepts.contains(response.status) || response.error == nil { resolve(.success)}
                    else if let error = response.error{ reject(error) }
                    }.catch(reject)
            } catch { reject(error) }
        }
    }
    
    @discardableResult override func delete(_ objects : [U]) -> Result {
        let _ : Promise<Result> = self.delete(objects)
        return .success
    }
    
    override func delete(_ objects : [U]) -> Promise<Result> {
        let allObjs = objects.map { $0.id }
        return Promise<Result> { resolve, reject in
            var req = Request(url: self.api.url, method: .delete, headers: self.api.headers, params: ["ids": allObjs], interceptor: self.api.interceptor)
            self.service.send(&req).then { response in
                if self.api.accepts.contains(response.status) || response.error == nil {
                    self.notify(R.event.deleted)
                    resolve(.success)
                }
                else if let error = response.error{
                    self.notify(R.event.error(error as Any))
                    reject(error)
                }
                }.catch { e in
                    self.notify(R.event.error(e as Any))
                    reject(e)
            }
        }
    }
    
    override func clearAll() -> DataSource<U>.Result {
        return .success
    }
    
    override func update(_ obj: U) -> Promise<DataSource<U>.Result> {
        return add(obj)
    }
    
    @discardableResult override func update(_ obj : U) -> Result {
        let _ : Promise<Result> = self.update(obj)
        return .success
    }
    
    override func list() -> [U] {
        return dataItems
    }
    
    override func load() -> Promise<[U]> {
        return Promise<[U]> { resolve, reject in
            var req = Request(url: self.api.url, method: Method.get, headers: self.api.headers, params: [:], interceptor: self.api.interceptor)
            let promise : Promise<Request> = self.service.send(&req)
            promise.then{ result in
                
                do {
                    if let res : [U] = try result.get() {
                        self.dataItems = res
                        resolve(res)
                    }
                } catch{
                    Log.error("error on parsing \(String(describing: U.self))", object: error)
                    if self.api.accepts.contains(result.status) {
                        self.dataItems = []
                        resolve([])
                    }
                    else if let error = result.error{ reject(error) }
                    else { reject(Errors.parseError) }
                }
                
                }.catch(reject)
        }
    }
    
    
    
}
