

import UIKit

class TestLayout: Layout {
    
    override func layout() -> [AnyObject] {
        return [
            
            UIView()
                .centerX(0)
                .centerY(0)
                .width(200)
                .height(200)
                .backgroundColor(.green)
        ]
    }
    
}

