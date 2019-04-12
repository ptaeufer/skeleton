import Foundation
import Promises

class RemotePaginatedDataSource<U: Identifiable & Codable> : RemoteDataSource<U> {
    
    struct Pagination : Codable {
        let lastId : String?
        let items : [U]
    }
    
    override func load() -> Promise<[U]> {
        return Promise { resolve, reject in
            var collection = [U]()
            func loadNext(_ next : Pagination?) {
                let url = next == nil ? self.api.url : "\(self.api.url)?lastId=\(next!.lastId!)"
                var req = Request(url: url , method: Method.get, headers: self.api.headers, params: [:], interceptor: self.api.interceptor)
                let promise : Promise<Request> = self.service.send(&req)
                promise.then{ result in
                    do {
                        if let res : Pagination = try result.get() {
                            collection.append(contentsOf: res.items)
                            if res.lastId == nil {
                                self.dataItems = collection
                                resolve(collection)
                            } else {
                                loadNext(res)
                            }
                        }
                    } catch{
                        Log.error("error on parsing \(String(describing: Pagination.self))", object: error)
                        if self.api.accepts.contains(result.status) {
                            self.dataItems = []
                            resolve([])
                        }
                        else if let error = result.error{ reject(error) }
                        else { reject(Errors.parseError) }
                    }
                    
                    }.catch(reject)
            }
            
            loadNext(nil)
            
        }
    }
    
    
}
