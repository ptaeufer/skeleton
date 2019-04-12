import Foundation


extension R.color : Codable {}
extension R.image : Codable {}
extension R.string {
    func with(color : R.color, for words : R.string...) -> NSAttributedString {
        
        let attribute = NSMutableAttributedString(string: self.string())
        words.forEach {
            let range = (self.string() as NSString).range(of: $0.string())
            attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: color.color , range: range)
        }
        
        return attribute
    }
}

extension String {
    func with(color : R.color, for words : String...) -> NSAttributedString {
        
        let attribute = NSMutableAttributedString(string: self)
        words.forEach {
            let range = (self as NSString).range(of: $0)
            attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: color.color , range: range)
        }
        
        return attribute
    }
}

extension NSMutableAttributedString {
    func with(color : R.color, for words : R.string...) -> NSAttributedString {
        
        words.forEach {
            let range = (self.string as NSString).range(of: $0.string())
            self.addAttribute(NSAttributedString.Key.foregroundColor, value: color.color , range: range)
        }
        
        return self
    }
}
