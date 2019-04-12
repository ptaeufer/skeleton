import UIKit
import Promises

extension UIView {
    @discardableResult
    func alpha(_ alpha : CGFloat) -> Self {
        self.alpha = alpha
        return self
    }
    
    @discardableResult
    func clipsToBounds(_ val : Bool) -> Self {
        self.clipsToBounds = val
        return self
    }
    
    @discardableResult
    func userInteractionEnabled(_ val : Bool) -> Self {
        self.isUserInteractionEnabled = val
        return self
    }
}

extension UIView {
    
    @objc
    dynamic var `height` : CGFloat {
        set {
            if let c = self.constraint(.height) {
                c.update(newValue)
            } else {
               self.height(newValue)
            }
        }
        get { return self.constraint(.height)?.value ?? self.frame.size.height}
    }
    
    @objc
    dynamic var `width` : CGFloat {
        set {
            if let c = self.constraint(.width) {
                c.update(newValue)
            } else {
                self.height(newValue)
            }
        }
        get { return self.constraint(.width)?.value ?? self.frame.size.width}
    }
    
    @objc
    dynamic var `bottom` : CGFloat {
        set {
            if let c = self.constraint(.bottom) {
                c.update(newValue)
            } else {
                self.height(newValue)
            }
        }
        get { return self.constraint(.bottom)?.value ?? 0}
    }
    
    @objc
    dynamic var `leading` : CGFloat {
        set {
            if let c = self.constraint(.leading) {
                c.update(newValue)
            } else {
                self.height(newValue)
            }
        }
        get { return self.constraint(.leading)?.value ?? 0}
    }
    
    @objc
    dynamic var `trailing` : CGFloat {
        set {
            if let c = self.constraint(.trailing) {
                c.update(newValue)
            } else {
                self.height(newValue)
            }
        }
        get { return self.constraint(.trailing)?.value ?? 0}
    }
    
    @objc
    dynamic var `top` : CGFloat {
        set {
            if let c = self.constraint(.top) {
                c.update(newValue)
            } else {
                self.height(newValue)
            }
        }
        get { return self.constraint(.top)?.value ?? 0}
    }

    
}

extension UIView {
    
    convenience init(layout : Layout) {
        self.init(frame : .zero)
        self.inflate(layout)
    }
    
    convenience init<T>(layout : Layout, binding : T) {
        self.init(frame : .zero)
        self.inflate(layout, binding)
    }
    
    @discardableResult func leading(_ val : CGFloat, to : R.id? = nil) -> Self {
        self._constraints.append(Constraint((.leading, .equal, to?.rawValue, val)))
        return self
    }
    
    @discardableResult func minWidth(_ val : CGFloat) -> Self {
        self._constraints.append(Constraint((.width, .greaterThanOrEqual, nil, val)))
        return self
    }
    
    @discardableResult func leading(_ val : CGFloat, to : UIView) -> Self {
        self._constraints.append(Constraint((.leading, .equal, to, val)))
        return self
    }
    
    @discardableResult func trailing(_ val : CGFloat, to : R.id? = nil) -> Self {
        self._constraints.append(Constraint((.trailing, .equal, to?.rawValue, val)))
        return self
    }
    
    @discardableResult func trailing(_ val : CGFloat, to : UIView) -> Self {
        self._constraints.append(Constraint((.trailing, .equal, to, val)))
        return self
    }
    
    
    @discardableResult func bottom(_ val : CGFloat, to : R.id? = nil) -> Self {
        self._constraints.append(Constraint((.bottom, .equal, to?.rawValue, val)))
        return self
    }
    
    @discardableResult func bottom(_ val : CGFloat, to : UIView) -> Self {
        self._constraints.append(Constraint((.bottom, .equal, to, val)))
        return self
    }
    
    @discardableResult func top(_ val : CGFloat, to : R.id? = nil) -> Self {
        self._constraints.append(Constraint((.top, .equal, to?.rawValue, val)))
        return self
    }
    
    @discardableResult func top(_ val : CGFloat, to : UIView) -> Self {
        self._constraints.append(Constraint((.top, .equal, to, val)))
        return self
    }
    
    @discardableResult func width(_ val : CGFloat, to : R.id? = nil, relation : NSLayoutConstraint.Relation = .equal) -> Self {
        self._constraints.append(Constraint((.width, relation, to?.rawValue, val)))
        return self
    }
    
    @discardableResult func height(_ val : CGFloat, to : R.id? = nil) -> Self {
        self._constraints.append(Constraint((.height, .equal, to?.rawValue, val)))
        return self
    }
    
    @discardableResult func centerX(_ val : CGFloat, to : R.id? = nil) -> Self {
        self._constraints.append(Constraint((.centerX, .equal, to?.rawValue, val)))
        return self
    }
    
    @discardableResult func centerY(_ val : CGFloat, to : R.id? = nil) -> Self {
        self._constraints.append(Constraint((.centerY, .equal, to?.rawValue, val)))
        return self
    }
    
    @discardableResult func tag(_ tagValue : Int) -> Self {
        self.tag = tagValue
        return self
    }
}

extension UIView : Configuration {
    
    
    private struct AssociatedKeys {
        static var constraints = "constraints"
        static var id = "id"
        static var controllerView = "controllerView"
    }
    
    var controllerView : Bool {
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.controllerView) as? Bool) ?? false }
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.controllerView,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
    }
    
    var id : R.id? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.id) as? R.id }
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.id,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _id = value { self.id(_id) }
        }
    }
    
    private var _constraints : [Constraint] {
        get {
            guard let c = objc_getAssociatedObject(self, &AssociatedKeys.constraints) as? [Constraint] else {
                self._constraints = [Constraint]()
                return self._constraints
            }
            return c
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.constraints,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func getView<T:UIView>(_ id : R.id) -> T? {
        return self.viewWithTag(id.rawValue.hash) as? T
    }
    
    func inflate(_ layout : Layout, callback : (()->Void)? = nil) {
        if let callback = callback {
            all(self.subviews.map({ $0.animate().alpha(0).promise()})).then { _ in
                self.inflate(layout.layout())
                self.layoutIfNeeded()
                self.subviews.forEach({$0.alpha = 0})
                callback()
                all(self.subviews.map({ $0.animate().alpha(1).promise()})).then{ _ in }
            }
        } else {
            self.inflate(layout.layout())
        }
    }
    
    
    func inflate<T>(_ layout : Layout, _ obj : T, callback : (()->Void)? = nil) {
        if let callback = callback {
            all(self.subviews.map({ $0.animate().alpha(0).promise()})).then { _ in
                self.inflate(layout.layout(Binding(obj)))
                self.subviews.forEach({$0.alpha = 0})
                callback()
                all(self.subviews.map({ $0.animate().alpha(1).promise()})).then{ _ in }
            }
        } else {
            self.inflate(layout.layout(Binding(obj)))
        }
        
    }
    
    private func inflate(_ views : [AnyObject]) {
        
        self.removeAllSubviews()
        views.forEach {
            if let v = $0 as? UIView {
                self.addSubview(v)
            }
        }
        
        func applyConstraints(_ v : UIView) {
            //v.translatesAutoresizingMaskIntoConstraints = false
            v.subviews.forEach { applyConstraints($0) }
            v.refreshConstraints()
        }
        
        self.subviews.forEach { applyConstraints($0) }
        

    }
    
    @objc func removeAllSubviews() {
        for _v in self.subviews {
            _v.removeFromSuperview()
        }
    }
    
    func refreshConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self._constraints.forEach {
            $0.apply(view: self)
        }
    }
    
    
    @discardableResult
    func id(_ id :R.id) -> Self {
        self.tag = id.rawValue.hash
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color :UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color :R.color) -> Self {
        self.backgroundColor(color.color)
        return self
    }
    @discardableResult
    func isHidden(_ isHidden : Bool) -> Self {
        self.isHidden = isHidden
        return self
    }
    
    @discardableResult
    func cornerRadius(_ radius : CGFloat) -> Self {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
        return self
    }
    
    @discardableResult
    func border(_ width : CGFloat = 1.0, color : UIColor = .black) -> Self {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        return self
    }
    
    @discardableResult
    func cornerRadius() -> Self {
        let h = self._constraints.filter({$0.attr() == .height}).first?.value ?? self.frame.size.height
        self.cornerRadius(h / 2)
        return self
    }
    
    func constraint(_ attr : NSLayoutConstraint.Attribute) -> Constraint? {
        return self._constraints.filter({ $0.attr() == attr}).first
    }
    
    @discardableResult
    func removeConstraint(_ attrs : NSLayoutConstraint.Attribute...) -> Self {
        attrs.forEach({ attr in
            self._constraints.filter({ $0.attr() == attr}).forEach{ $0.remove()}
            self._constraints.removeAll { $0.attr() == attr }
        })
        return self
    }
    
    @discardableResult
    func children(_ children : [AnyObject]) -> Self {
        children.forEach {
            if let v = $0 as? UIView {
                self.addSubview(v)
            }
        }
        return self
    }

    @discardableResult
    func on(click : @escaping ()->Void) -> Self {
        UITapGestureRecognizer(addToView: self, closure: click)
        return self
    }
 
    @discardableResult
    func on(click : R.event) -> Self {
        self.isUserInteractionEnabled = true
        UITapGestureRecognizer(addToView: self, closure: {
            self.notify(event: click)
        })
        return self
    }
    
    func notify(event : R.event) {
        var parentResponder: UIResponder? = self.superview
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let listener = parentResponder as? EventListener {
                listener.on(event : event)
                break;
            }
        }
    }
    
    @discardableResult
    func style(_ style : [String:Any]) -> Self {
        
        for (key,val) in style {
            var _val = val
            if let v = _val as? R.color { _val = v.color}
            if let v = _val as? R.string { _val = v.string}
            if let v = _val as? R.image { _val = v.image}
            let comps = key.components(separatedBy: ".")
            var current : AnyObject? = self
            comps.forEach { _key in
                if _key == comps.last {
                    current?.setValue(_val, forKey: _key)
                } else {
                    current = current?.value(forKey: _key) as AnyObject
                }
            }
        }
        return self
    }
    
    @discardableResult
    func shadow(radius: CGFloat = 2.0, opacity: Float = 0.6, color: UIColor = .darkGray, offset: CGSize = CGSize(width: -2, height: 2)) -> Self {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
        return self
    }
    
}

extension UIView {
    private static let kRotationAnimationKey = "rotationanimationkey"
    
    func rotate(duration: Double = 1) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }
    
    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
}
