import UIKit

extension UITabBar {
    
    @discardableResult
    func barStyle( _ style : UIBarStyle) -> UITabBar {
        self.barStyle = style
        return self
    }
    
}
