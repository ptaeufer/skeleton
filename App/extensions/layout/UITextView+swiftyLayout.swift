import UIKit

extension UITextView {
    
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
    
    @discardableResult func textAlignment(_ alignment : NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
}
