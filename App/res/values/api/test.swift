import Foundation

struct testAPI : API {
    let url: String = R.url.test
    var accepts: [Int] = []
    var headers: Headers = [:]
    var interceptor: Interceptor? = Interceptor(
        before : { req in
            // actions before request
        },
        after : { req in
            // actions after request
        }
    )
    
}


