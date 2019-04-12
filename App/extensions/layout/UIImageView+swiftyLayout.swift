import UIKit

extension UIImageView {
    @discardableResult func image(_ image : R.image?) -> UIImageView {
        return self.image(image?.image)
    }
    
    @discardableResult func image(_ image : UIImage?) -> UIImageView {
        if self.image?.renderingMode == .alwaysTemplate {
            self.image = image?.withRenderingMode(.alwaysTemplate)
        } else { self.image = image }
        
        return self
    }
    
    @discardableResult
    func contentMode(_ mode : UIView.ContentMode) -> UIImageView {
        self.contentMode = mode
        return self
    }
    
    
    @discardableResult func tintColor(_ color : R.color) -> Self {
        self.tintColor(color.color)
        return self
    }
    
    @discardableResult func tintColor(_ color : UIColor) -> Self {
        self.image = (self.image ?? UIImage()).withRenderingMode(.alwaysTemplate)
        self.tintColor = color
        return self
    }
    

}

