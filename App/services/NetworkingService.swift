import Foundation
import Alamofire
import Promises


class NetworkingService : SessionDelegate {
    
    private let sessionManager = SessionManager()
    
    func send(_ req : inout Request) -> Promise<Request> {
        var req = req
        return Promise<Request> { resolve, reject in
            
            req.interceptor?.before?(&req)
            if req.canceled { return reject(req.error!) }
            
            let encoding : ParameterEncoding = ([.post, .delete].contains(req.method) ? JSONEncoding.default : URLEncoding.default)
            let _ = self.sessionManager.request(req.url, method: req.method, parameters: req.params, encoding: encoding, headers: req.headers)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    //Log.debug("\(req.url) \(req.method.rawValue)", object: response)
                    let statusCode = response.response?.statusCode ?? -1
                    switch response.result {
                    case .success, .failure :
                        req.status = statusCode
                        req.json = response.value
                        req.error = response.error
                        req.result = response.data
                        req.interceptor?.after?(&req)
                        req.log()
                        resolve(req)
                    }
            }
        }
    }
    
    private func enrichHeaders( headers : inout HTTPHeaders) {
        
    }
}
