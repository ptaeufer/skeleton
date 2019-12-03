import UIKit

public protocol Configuration {}

extension Configuration {
    /*
    public func apply(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
    */
}

extension Dictionary where Iterator.Element == (key: String, value: Any) { func extend(_ ext : [String:Any]) -> Dictionary<String,Any> { return self.merging(ext) { (_, new) in new } } }
class RawResource : NSObject {typealias Style = [String:Any]; }; @objcMembers class Resource : NSObject { typealias Style = [String:Any]; override init() {}}

extension UITableView {
    
    private struct AssociatedKeys {
        static var adapter = "adapter"
    }
    
    var adapter : Adapter? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.adapter) as? Adapter
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.adapter,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult func adapter(_ adapter : Adapter) -> UITableView {
        self.rowHeight = UITableView.automaticDimension
        self.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.dataSource = adapter
        self.delegate = adapter
        self.allowsMultipleSelection = false
        self.allowsSelection = true
        self.adapter = adapter
        adapter.setList(self)
        return self
    }
}

extension UIViewController{
    
    func getView<T:UIView>(_ id : R.id) -> T? {
        return view.getView(id) as? T
    }
    
    func inflate(_ layout : Layout, _ callback : (()->Void)? = nil) {
        self.view.inflate(layout, callback : callback)
    }
    
    func inflate<T>(_ layout : Layout, _ obj : T, _ callback : (()->Void)? = nil) {
        self.view.inflate(layout, obj, callback : callback)
    }
}


extension R.string {
    func string(_ args: CVarArg...) -> String {
        
        if args.count == 0 {
            return NSLocalizedString("\(self.rawValue)", comment: "")
        } else {
            return String(format: NSLocalizedString("\(self.rawValue)", comment: ""), arguments: args)
        }
    }
    
    func quantityString(args: CVarArg...) -> String {
        if let amount = args[0] as? NSNumber{
            if amount.intValue > 1 {
                return String(format: NSLocalizedString("\(self.rawValue).other", comment: ""), amount.intValue)
            } else {
                return String(format: NSLocalizedString("\(self.rawValue).one", comment: ""),  amount.intValue)
            }
        } else {
            return ""
        }
    }
}

extension R.font {
    var font : UIFont {
        if let font = UIFont(name: self.get(), size: UIFont.systemFontSize) {
            return font
        }
        return UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.light)
    }
    
    func size(_ size : CGFloat) -> UIFont{
        if let font = UIFont(name: self.get(), size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.light)
    }
    
}

extension R.color {
    var color : UIColor {
        if let color : String = self.get() {
            return UIColor(hex : color)
        }
        return UIColor(hex: self.rawValue)
    }
}

extension R.image {
    var image : UIImage {
        return UIImage(named: self.rawValue, in: Bundle(for: R.self), compatibleWith: nil)!
    }
}

/*
extension R.style {
    var style : [String:Any] {
        return ResourcePool.style.value(forKey: self.rawValue) as? [String:Any] ?? [:]
    }
    
    func extend(_ ext : [String:Any]) -> [String:Any] {
        var _e : [String:Any] = self.get()
        return _e.extend(ext)
    }
    
}*/

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
}




protocol Bindable {
    associatedtype TYPE
    var object : TYPE {get}
    init(_ obj : TYPE)
}

class Binding<S> : Bindable {
    let object : S
    required init(_ obj: S) {
        self.object = obj
    }
}


class Layout {
    func layout() -> [AnyObject] {
        return []
    }
    func layout<T:Bindable>(_ binding : T) -> [AnyObject] {
        return []
    }
}

protocol EventListener {
    func on(event : R.event)
}

class Observable  {
    
    let _observers = NSPointerArray.weakObjects()
    func notify(_ event : R.event) {
        _observers.allObjects.each {  index,o  in
            guard let pointer = _observers.pointer(at: index), let observer = Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue() as? EventListener else { return }
            DispatchQueue.main.async {
                observer.on(event: event)
            }
            
        }
    }
    
    func register(_ observer : EventListener) {
        _observers.addPointer(Unmanaged.passUnretained(observer as AnyObject).toOpaque())
    }
}

extension UITapGestureRecognizer {
    @discardableResult convenience init(addToView targetView: UIView,
                                        closure: @escaping (UIView) -> Void) {
        self.init()
        
        GestureTarget.add(gesture: self,
                          closure: closure,
                          toView: targetView)
    }
}

class GestureTarget: UIView {
    class ClosureContainer {
        weak var gesture: UIGestureRecognizer?
        let closure: ((UIView) -> Void)
        
        init(closure: @escaping (UIView) -> Void) {
            self.closure = closure
        }
    }
    
    var containers = [ClosureContainer]()
    
    convenience init() {
        self.init(frame: .zero)
        isHidden = true
    }
    
    static func add(gesture: UIGestureRecognizer, closure: @escaping (UIView) -> Void,
                    toView targetView: UIView) {
        let target: GestureTarget
        if let existingTarget = existingTarget(inTargetView: targetView) {
            target = existingTarget
        } else {
            target = GestureTarget()
            targetView.addSubview(target)
        }
        let container = ClosureContainer(closure: closure)
        container.gesture = gesture
        target.containers.append(container)
        
        gesture.addTarget(target, action: #selector(GestureTarget.target(gesture:)))
        targetView.addGestureRecognizer(gesture)
    }
    
    static func existingTarget(inTargetView targetView: UIView) -> GestureTarget? {
        for subview in targetView.subviews {
            if let target = subview as? GestureTarget {
                return target
            }
        }
        return nil
    }
    
    func cleanUpContainers() {
        containers = containers.filter({ $0.gesture != nil })
    }
    
    @objc func target(gesture: UIGestureRecognizer) {
        cleanUpContainers()
        
        for container in containers {
            guard let containerGesture = container.gesture else {
                continue
            }
            
            if gesture === containerGesture {
                container.closure(self)
            }
        }
    }
}

