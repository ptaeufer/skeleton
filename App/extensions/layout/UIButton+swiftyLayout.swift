import UIKit

extension UIButton {

    @objc dynamic var textColor : UIColor? {
        get { return titleLabel?.textColor }
        set(value) { setTitleColor(value, for: .normal) }
    }
    
    @discardableResult func text(_ text : R.string, _ args : CVarArg...) -> UIButton {
        return self.text(text.string(args))
    }
    
    @discardableResult func text(_ text : String?) -> UIButton {
        self.setTitle(text, for: .normal)
        return self
    }
    
    @discardableResult func textColor(_ color : R.color) -> UIButton {
        return self.textColor(color.color)
    }
    
    @discardableResult func textColor(_ color : UIColor) -> UIButton {
        self.textColor = color
        return self
    }
    @discardableResult func font(_ font : R.font) -> Self {
        self.font(font.font)
        return self
    }
    
    @discardableResult func font(_ font : UIFont) -> UIButton {
        self.titleLabel?.font = font
        return self
    }
    
    @discardableResult func image(_ image : R.image) -> UIButton {
        self.setImage(image.image, for: .normal)
        return self
    }
    
    @discardableResult func image(_ image : R.image, tint: UIColor) -> UIButton {
        self.setImage(image.image.withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = tint
        return self
    }
    
    @discardableResult func image(_ image : UIImage) -> UIButton {
        self.setImage(image, for: .normal)
        return self
    }
    
    
}
