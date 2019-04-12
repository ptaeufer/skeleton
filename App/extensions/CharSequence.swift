import UIKit

extension UILabel {
    @discardableResult func set(text : CharSequence) -> Self {
        if let text = text as? String {
            self.text = text
        } else if let text = text as? NSAttributedString {
            self.attributedText = text
        }
        return self
    }
}

extension UITextView {
    @discardableResult func set(text : CharSequence) -> Self {
        if let text = text as? String {
            self.text = text
        } else if let text = text as? NSAttributedString {
            self.attributedText = text
        }
        return self
    }
}

protocol CharSequence {
    
}

extension CharSequence {
    
    var count : Int  {
        if let _self = self as? String {
            return _self.count
        } else if let _self = self as? NSAttributedString {
            return _self.string.count
        }
        return 0
    }
}
extension NSAttributedString : CharSequence{}
extension String : CharSequence{}
