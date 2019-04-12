
import Foundation

@dynamicMemberLookup
public struct DynamicLookupProxy {
    private let dict: [String: Any]
    public init(_ dict: [String: Any]) {
        self.dict = dict
    }
    
    public subscript<T>(dynamicMember member: String) -> T? {
        return dict[member] as? T
    }
    public subscript(dynamicMember member: String) -> Any? {
        return dict[member]
    }
}

postfix operator ^
public postfix func ^ (lhs: [String: Any]) -> DynamicLookupProxy {
    return DynamicLookupProxy(lhs)
}
