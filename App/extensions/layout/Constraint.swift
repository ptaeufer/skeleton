import UIKit


class Constraint : NSObject {
    private var toView : UIView?
    private var to : String?
    private var offset : CGFloat
    private var attribute : NSLayoutConstraint.Attribute
    private var relation : NSLayoutConstraint.Relation
    private var otherAttribute : NSLayoutConstraint.Attribute?
    
    private var _view : UIView?
    private var _constraint : NSLayoutConstraint?
    private var _tryCount = 0
    
    init(_ params : (NSLayoutConstraint.Attribute, NSLayoutConstraint.Relation, String?, CGFloat?)) {
        self.attribute = params.0
        self.relation = params.1
        self.to = params.2
        self.offset = params.3 ?? 0
    }
    
    init(_ params : (NSLayoutConstraint.Attribute, NSLayoutConstraint.Relation, String?, NSLayoutConstraint.Attribute, CGFloat)) {
        self.attribute = params.0
        self.relation = params.1
        self.to = params.2
        self.otherAttribute = params.3
        self.offset = params.4
    }
    
    
    init(_ params : (NSLayoutConstraint.Attribute, NSLayoutConstraint.Relation, UIView, CGFloat)) {
        self.attribute = params.0
        self.relation = params.1
        self.toView = params.2
        self.offset = params.3
    }
    
    init(_ constraint : NSLayoutConstraint) {
        self._constraint = constraint
        self.offset = constraint.constant
        self.attribute = constraint.firstAttribute
        self.otherAttribute = constraint.secondAttribute
        self.relation = constraint.relation
        self._view = constraint.firstItem as? UIView
    }
    
    
    func remove() {
        if let c = _constraint {
            NSLayoutConstraint.deactivate([c])
        }
    }
    
    func update(_ newValue : CGFloat, _ duration : Double? = nil, completion : ((Bool)->Void)? = nil) {
        self.offset = newValue
        if self._view != nil {
            self.apply(view: _view!)
        }
        
        if let duration = duration {
            var _v : UIView?
            var next : AnyObject? = self._view
            while next?.next != nil {
                next = next?.next
                if let responder = next as? UIViewController {
                    _v = responder.view
                    break;
                }
            }
            
            UIView.animate(withDuration: duration, animations: {
                (_v ?? self._view?.superview)?.layoutIfNeeded()
            }, completion: completion)
        } else {
            self._view?.superview?.layoutIfNeeded()
        }
    }
    
    var value : CGFloat {
        return self.offset
    }
    
    
    func apply(view : UIView) {
        self._tryCount += 1
        self.remove()
        var _offset = self.offset
        self._view = view
        
        var toView : UIView? = attribute != .height && attribute != .width ? view.superview : nil
        var attr = attribute
        
        if let tv = self.toView {
            toView = tv
            attr = getAttribute(attr)
        }
        
        if let id = self.to {
            
            func relateToOther(_ view : UIView?) -> Bool {
                if let toItem = view?.viewWithTag(id.hash) {
                    self._tryCount = 0
                    toView = toItem
                    attr = getAttribute(attr)
                    return true
                } else {
                    return false
                }
            }
            
            var sv = view.superview
            while !relateToOther(sv) && sv != nil {
                sv = sv?.superview
            }
            if sv == nil {
                fatalError("no view with given id found")
            }
            
        }
        
        
        var toItem : Any? = toView
        if (attribute == .bottom || attribute == .top) && toView?.controllerView == true
        {
            toItem = toView?.safeAreaLayoutGuide
        }
        
        if toView == view.superview && (attribute == .bottom || attribute == .trailing) && _offset != 0 {
            _offset = -self.offset
        }
        if _offset > 0 && _offset < 1 {
            _constraint = NSLayoutConstraint(item: view, attribute: attribute, relatedBy: relation, toItem: toItem ?? view.superview, attribute: toView ?? view.superview != nil ? attr : .notAnAttribute, multiplier: self.offset, constant: 0)
        } else {
            _constraint = NSLayoutConstraint(item: view, attribute: attribute, relatedBy: relation, toItem: toItem, attribute: toView != nil ? attr : .notAnAttribute, multiplier: 1, constant: _offset)
        }
        
        
        
        NSLayoutConstraint.activate([_constraint!])
        
    }
    
    private func getAttribute(_ attr : NSLayoutConstraint.Attribute) -> NSLayoutConstraint.Attribute {
        
        if let a = self.otherAttribute {
            return a
        }
        
        switch attr {
        case .bottom:
            return .top
        case .top:
            return .bottom
        case .leading:
            return .trailing
        case .trailing:
            return .leading
        default:
            return attr
        }
    }
    
    func attr() -> NSLayoutConstraint.Attribute {
        return self.attribute
    }
}
