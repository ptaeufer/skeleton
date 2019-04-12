import Foundation

extension String {
    func regexMatches(pattern: String) -> Array<String> {
        let re: NSRegularExpression
        do {
            re = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return []
        }
        
        let matches = re.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        var collectMatches: Array<String> = []
        for match in matches {
            let substring = (self as NSString).substring(with: match.range(at: 1))
            collectMatches.append(substring)
        }
        return collectMatches
    }
    
    var int : Int? {
        return Int(self)
    }
    
    var bool : Bool? {
        return Bool(self)
    }
    
 
}
