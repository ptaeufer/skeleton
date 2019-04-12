import UIKit

class GradientView : UIView {
    
    private let gradient = CAGradientLayer()
    
    init(colors : [UIColor]? = nil) {
        super.init(frame : CGRect.zero)
        if let colors = colors {
            self.setColors(colors)
        }
        self.layer.addSublayer(gradient)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColors(_ colors : [UIColor]) {
        gradient.colors = colors.map { $0.cgColor }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.gradient.frame.origin = CGPoint.zero
        self.gradient.frame.size = self.frame.size
    }
    
}

