import Foundation

enum Errors : LocalizedError {
    case incomplete, parseError, canceled, noTanAvailable, notImplemented, unexpectedHttpResponseCode, typeException, responseStatusError(status: Int, message: String)
    
    var errorDescription: String {
        return localizedDescription
    }
    
    var localizedDescription: String {
        switch self {
        case let .responseStatusError(_, message): return message
        default : return "Ohh no! something went wrong"
        }
    }
}

