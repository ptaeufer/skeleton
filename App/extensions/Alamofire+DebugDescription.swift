import Foundation
import Alamofire

extension Alamofire.Request {
    open var customDebugDescription: String {
        var components: [String] = []
        
        components.append("\n------------------------------------")
        if let HTTPMethod = request?.httpMethod, let urlString = request?.url?.absoluteString {
            components.append(HTTPMethod + " " + urlString)
        }
        
        if let response = response {
            components.append("status code (\(response.statusCode))")
        }
        
        var headers: [AnyHashable: Any] = [:]
        if let additionalHeaders = session.configuration.httpAdditionalHeaders {
            for (field, value) in additionalHeaders where field != AnyHashable("Cookie") {
                headers[field] = value
            }
        }
        if let headerFields = request?.allHTTPHeaderFields {
            for (field, value) in headerFields where field != "Cookie" {
                headers[field] = value
            }
        }
        
        components.append("Headers : ")
        for (field, value) in headers {
            components.append("\t \(field): \(value)")
        }
        
        components.append("Body Parameters : ")

        
        if let httpBodyData = request?.httpBody, var httpBody = String(data: httpBodyData, encoding: .utf8) {
            httpBody = httpBody.replacingOccurrences(of: "{", with: "")
            httpBody = httpBody.replacingOccurrences(of: "}", with: "")
            let bodyComponents = httpBody.components(separatedBy: ",")
            components.append(contentsOf: bodyComponents.map {"\t" + $0})
        }
        components.append("------------------------------------\n")
        
        return components.joined(separator: "\n")
    }
}
