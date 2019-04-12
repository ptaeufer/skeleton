import UIKit

func after(_ time : Double, block :@escaping ()->Void) {
    let time = DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds) + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time, execute: block)
}

class Context {
    
    static var current : Context?
    
}
