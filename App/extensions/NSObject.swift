import Foundation

protocol HasApply { }

extension HasApply {
    func apply(_ closure:(Self) -> ()) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: HasApply { }

extension Dictionary {
    func with(_ ext : [Key:Value]) -> Dictionary<Key,Value> {
        return self.merging(ext) { (_, new) in new }
        
    }
    
}
