import UIKit

extension UIScrollView {
    
    @discardableResult
    func paging(_ val : Bool) -> Self {
        self.isPagingEnabled = val
        return self
    }
    
    @discardableResult
    func delegate(_ delegate : UIScrollViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }
    
}
