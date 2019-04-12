import Foundation
import Alamofire

typealias Headers = [String: String]
typealias Method = HTTPMethod
typealias Parameters = [String : Any]


struct Interceptor {
    let before : ((inout Request) -> Void)?
    let after : ((inout Request) -> Void)?
}

protocol API {
    var url : String { get }
    var accepts : [Int]  { get }
    var headers : Headers  { get }
    var interceptor : Interceptor? { get }
}

struct Request {
    var url : String
    var method : Method
    var headers : Headers
    var params : Parameters
    var interceptor : Interceptor?
    var status : Int = -1
    var json: Any?
    var result : Data?
    var canceled : Bool = false
    var error : Error? = nil
    
    func get<T:Codable>() throws -> T {
        let decoder = CustomJSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        do {
           return try decoder.decode(T.self, from: self.result!)
        } catch {
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: self.result!)
        }
    }
    
    init(url : String, method : HTTPMethod) {
        self.init(url: url, method: method, headers: [:], params: [:], interceptor: nil)
    }
    
    init(url : String, method : HTTPMethod, params : Parameters) {
        self.init(url: url, method: method, headers: [:], params: params, interceptor: nil)
    }
    init(url : String, method : HTTPMethod, headers : HTTPHeaders) {
        self.init(url: url, method: method, headers: headers, params: [:], interceptor: nil)
    }
    
    init(url : String, method : HTTPMethod, headers : HTTPHeaders, params : Parameters, interceptor : Interceptor? ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.params = params
        self.interceptor = interceptor
    }
    
    mutating func cancel(_ error : Error) {
        self.error = error
        self.canceled = true
    }
    
    func log() {
        print("------------------------------------")
        print("\(self.method) \(self.url)")
        do {
            print("Headers : ", try JSONSerialization.jsonObject(with: JSONSerialization.data(withJSONObject: headers, options: .prettyPrinted), options: []))
            print("Body Parameters : ", try JSONSerialization.jsonObject(with: JSONSerialization.data(withJSONObject: params, options: .prettyPrinted), options: []))
            print("Response : ", status)
            if let result = result {
                print("Response Body Length: \(result.count)")
                if result.count < 1000 {
                    print("Response Body: ", try JSONSerialization.jsonObject(with: result, options: []))
                }
            }
        } catch {}
        print("------------------------------------")
    }
}
