import Foundation

extension Encodable {
    func dictionary() throws -> [String: Any] {
        let data = try CustomJSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension KeyedDecodingContainer {
    func decodeDate(_ key: Key) throws -> Date {
        do {
            let date = try self.decode(Date.self, forKey: key)
            return date
        }
        catch {
            let dateString = try self.decode(String.self, forKey: key)
            if let date = DateFormatter.iso8601Full.date(from: dateString) {
                return date
            }
            else {
                throw error
            }
        }
    }
}
