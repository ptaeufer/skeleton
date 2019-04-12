import Foundation

class CustomJSONDecoder : JSONDecoder {
    
    override init() {
        super.init()
        self.dateDecodingStrategy = .iso8601
    }
}
class CustomJSONEncoder : JSONEncoder {
    override init() {
        super.init()
        self.dateEncodingStrategy = .iso8601
    }
}


extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }()
}
