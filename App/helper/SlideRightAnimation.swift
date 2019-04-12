import UIKit

class SlideRightAnimation: NSObject,UIViewControllerAnimatedTransitioning {

    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
        let fromView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)
        
        toView.frame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        let fromNewFrame = CGRect(x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            fromView.frame = fromNewFrame
        }, completion: { (Bool) -> Void in
            transitionContext.completeTransition(true)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    
}
