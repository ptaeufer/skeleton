import UIKit

class R{
    static let constants = Constants();
    static let info = Info();
    static let url = Url();
    static let style = Style();



    enum font : String {

        case primary

        func get<T>() -> T! {
            return (ResourcePool.font.value(forKey: self.rawValue) as! T)
        }
    }



    enum color : String {

        case primary
        case secondary

        func get<T>() -> T! {
            return (ResourcePool.color.value(forKey: self.rawValue) as! T)
        }
    }


    enum layout {
        static let ToastLayout = ResourcePool.ToastLayout_internal;

    }


    enum id : String {

        case action
        case text

        func get<T>() -> T! {
            return (self.rawValue as! T)
        }

    }



    enum event {

        case add(Any)
        case datasource_add
        case datasource_delete
        case datasource_update
        case delete(Any)
        case deleteAll
        case deleteMany(Any)
        case deleted
        case error(Any)
        case keyboardWillHide(Any)
        case keyboardWillShow(Any)
        case loaded(Any)
        case loading(Any)
        case not_initialized
        case selected(Any)
        case update(Any)

        enum plain : String {

            case add
            case datasource_add
            case datasource_delete
            case datasource_update
            case delete
            case deleteAll
            case deleteMany
            case deleted
            case error
            case keyboardWillHide
            case keyboardWillShow
            case loaded
            case loading
            case not_initialized
            case selected
            case update

        }

        var plainEvent : R.event.plain {
            switch self {
                case .add: return R.event.plain.add
                case .datasource_add: return R.event.plain.datasource_add
                case .datasource_delete: return R.event.plain.datasource_delete
                case .datasource_update: return R.event.plain.datasource_update
                case .delete: return R.event.plain.delete
                case .deleteAll: return R.event.plain.deleteAll
                case .deleteMany: return R.event.plain.deleteMany
                case .deleted: return R.event.plain.deleted
                case .error: return R.event.plain.error
                case .keyboardWillHide: return R.event.plain.keyboardWillHide
                case .keyboardWillShow: return R.event.plain.keyboardWillShow
                case .loaded: return R.event.plain.loaded
                case .loading: return R.event.plain.loading
                case .not_initialized: return R.event.plain.not_initialized
                case .selected: return R.event.plain.selected
                case .update: return R.event.plain.update
            }
        }

    }



    enum image : String {

        case none

        func get<T>() -> T! {
            return (self.rawValue as! T)
        }

    }



    enum string : String {

        case NSHealthShareUsageDescription
        case NSHealthUpdateUsageDescription
        case NSPhotoLibraryUsageDescription

        func get<T>() -> T! {
            return (self.rawValue as! T)
        }

    }

}
@objcMembers class ResourcePool : NSObject{ static let font = Font(); static let color = Color(); static let ToastLayout_internal = ToastLayout(); }
extension Dictionary where Iterator.Element == (key: String, value: Any) { func extend(_ ext : [String:Any]) -> Dictionary<String,Any> { return self.merging(ext) { (_, new) in new } } }
class RawResource : NSObject {typealias Style = [String:Any]; }; @objcMembers class Resource : NSObject { typealias Style = [String:Any]; override init() {}}
