import Foundation
class Injector{
    public static let dependencies : Dictionary<Injector.classes,()->AnyObject> = [
        :
    ]
}
extension Injector{
    enum classes : String {
        case none
        static func fromClassName(_ name : String) -> classes {
            return Injector.classes(rawValue : name) ?? .none
        }
    }
}
open class DependencyModule{}
func inject<T>() -> T {
    return inject(String(describing : T.self))
}
func inject<T>(_ c : T.Type) -> T {
    return inject(String(describing : c))
}
private func inject<T>(_ name : String) -> T {
    if let dep : ()->AnyObject =  Injector.dependencies[Injector.classes.fromClassName(name)], let obj = dep() as? T {
        return obj
    }
    fatalError("dependency for \(name).self not found")
}