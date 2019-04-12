import Foundation

class Info: RawResource {
    
    let version : String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    let buildNumber : String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    let bundleId : String = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "unknown"
    
}
