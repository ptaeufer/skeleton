import UIKit

extension UILabel {
    
    @discardableResult func text(_ text : R.string, _ args : CVarArg...) -> Self {
        return self.text(text.string(args))
    }
    
    @discardableResult func text(_ text : String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult func font(_ font : R.font) -> Self {
        self.font(font.font)
        return self
    }
    
    @discardableResult func font(_ font : UIFont) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult func textColor(_ color : R.color) -> Self {
        return self.textColor(color.color)
    }
    
    @discardableResult func textColor(_ color : UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    @discardableResult func letterSpacing(_ value : CGFloat) -> Self {
        self.letterSpacing = value
        return self
    }
    
    
    @discardableResult func textAlignment(_ alignment : NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    @discardableResult func adjustFontSize(_ type : Bool) -> Self {
        self.adjustsFontSizeToFitWidth = type
        return self
    }
    
    @discardableResult func numberOfLines(_ lines : Int) -> Self {
        self.numberOfLines = lines
        return self
    }
    
    @discardableResult func attributedText(_ text : String, attributes: [NSAttributedString.Key: Any]) -> Self {
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        self.attributedText = attributedText
        return self
    }
    @discardableResult func attributedText(_ text : NSAttributedString) -> Self {
        self.attributedText = attributedText
        self.sizeToFit()
        return self
    }
    
    @discardableResult func underlinedText(_ text : String) -> Self {
        return self.attributedText(text, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    @objc
    dynamic var letterSpacing: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            }
            else {
                attributedString = NSMutableAttributedString(string: text ?? "")
                text = nil
            }
            
            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: newValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            
            attributedText = attributedString
        }
        
        get {
            if let currentLetterSpace = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            }
            else {
                return 0
            }
        }
    }
}


