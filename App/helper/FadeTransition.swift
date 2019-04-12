import UIKit
import Promises

class FadeTransition: NSObject,UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let from : UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let to : UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(from)
        transitionContext.containerView.addSubview(to)
        
        from.subviews.forEach({ $0.alpha = 0})
        all(from.subviews.map({ $0.animate().alpha(0).promise()})).then {_ in}
        all(to.subviews.map({ $0.animate().alpha(1).promise()})).delay(0.2).then { _ in
            transitionContext.completeTransition(true)
        }

    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
}
