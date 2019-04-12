import UIKit
import Promises

extension UIView {
    func animate() -> Animator {
        return Animator(self)
    }
}

class Animator {
    
    private var view : UIView
    private var _viewTransform : CGAffineTransform!
    private var _viewAlpha : CGFloat!
    
    private var _scale : CGFloat?
    private var _translateX : CGFloat?
    private var _translateY : CGFloat?
    private var _rotateAngle : CGFloat?
    private var _alpha : CGFloat?
    private var _revert : Bool = false
    private var _damping : CGFloat?
    private var _velocity : CGFloat?
    private var _duration : Double = 0.4
    private var _easing : UIView.AnimationOptions = .curveEaseInOut
    private var _delay : Double = 0
    private var _done : ((UIView)->Void)?
    
    init(_ view : UIView) {
        self.view = view
        self._viewTransform = view.transform
        self._viewAlpha = view.alpha
    }
    
    func animate(view : UIView) {
        self.view = view
        self._viewTransform = view.transform
        self._viewAlpha = view.alpha
        self.start()
    }
    
    @discardableResult func scale(_ value : CGFloat) -> Animator { self._scale = value; return self }
    @discardableResult func translateX(_ value : CGFloat) -> Animator { self._translateX = value; return self }
    @discardableResult func translateY(_ value : CGFloat) -> Animator { self._translateY = value; return self }
    @discardableResult func alpha(_ value : CGFloat) -> Animator { self._alpha = value; return self }
    @discardableResult func damping(_ value : CGFloat) -> Animator { self._damping = value; return self }
    @discardableResult func velocity(_ value : CGFloat) -> Animator { self._velocity = value; return self }
    @discardableResult func duration(_ value : Double) -> Animator { self._duration = value; return self }
    @discardableResult func rotate(_ value : Double) -> Animator { self._rotateAngle = CGFloat(value); return self }
    @discardableResult func delay(_ value : Double) -> Animator { self._delay = value; return self }
    @discardableResult func easing(_ value : UIView.AnimationOptions) -> Animator { self._easing = value; return self }
    @discardableResult func revert() -> Animator { self._revert = true; return self }
    @discardableResult func onComplete(_ callback : @escaping ((UIView)->Void)) -> Animator { self._done = callback; return self }
    
    func promise() -> Promise<UIView> {
        return Promise(on : DispatchQueue.main) { resolve, reject in
            self._done = { view in
                resolve(view)
            }
            self.start()
        }
    }
    
    func start(_ revert : Bool = false) {
        
        func anim() {
            if let a = self._alpha {
                self.view.alpha = revert ? self._viewAlpha : a
            }
            var transform : CGAffineTransform?
            
            if !revert {
                if let scale = self._scale {
                    transform = CGAffineTransform(scaleX: scale, y: scale)
                }
                if let t = self._translateX {
                    transform = transform == nil ? CGAffineTransform(translationX: t, y: 0) : transform?.concatenating(CGAffineTransform(translationX: t, y: 0))
                }
                if let t = self._translateY {
                    transform = transform == nil ? CGAffineTransform(translationX: 0, y: t) : transform?.concatenating(CGAffineTransform(translationX: 0, y: t))
                }
                
                if let r = self._rotateAngle {
                    transform = transform == nil ? CGAffineTransform(rotationAngle: r) : transform?.concatenating(CGAffineTransform(rotationAngle: r))
                }
            } else {
                transform = self._viewTransform
            }
            
            if let transform = transform {
                self.view.transform = transform
            }
            
        }
        
        func complete(_ complete : Bool) {
            if self._revert && !revert {
                self.start(true)
            } else {
                self._done?(view)
            }
        }
        
        DispatchQueue.main.async{
            if let damping = self._damping, let velocity = self._velocity {
                UIView.animate(
                    withDuration: self._duration,
                    delay: self._delay,
                    usingSpringWithDamping: damping,
                    initialSpringVelocity: velocity,
                    options: self._easing,
                    animations: anim,
                    completion: complete)
            } else {
                UIView.animate(
                    withDuration: self._duration,
                    delay: self._delay,
                    options: self._easing,
                    animations: anim,
                    completion: complete)
            }
            
        }
        
    }
}
