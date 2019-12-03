import UIKit
class R { 
    static let constants = Constants()
    static let info = Info()
    static let url = Url()
    static let style = Style()
    enum font : String {
        case primary
    }
    enum color : String {
        case primary
        case secondary
        case colorDarkGrey
    }
    enum image : String {
        case lock
    }
    enum string : String {
        case ok 
    }
    enum id : String {
        case action
        case text
    }
    enum layout {
        static let toastLayout  = ToastLayout()
        static let testLayout = TestLayout()
    }
    enum event {
        case selected(Any)
        enum plain : String {
            case selected
        }
        var plainEvent : R.event.plain {
            switch self {
            case .selected: return R.event.plain.selected
            }
        }
    }
}
@objcMembers class ResourcePool : NSObject {
    static let font = Font()
    static let color = Color()
}
extension R.font {
    func get<T>() -> T! {
        return (ResourcePool.font.value(forKey: self.rawValue) as! T)
    }
}
extension R.color {
    func get<T>() -> T! {
        return (ResourcePool.color.value(forKey: self.rawValue) as! T)
    }
}