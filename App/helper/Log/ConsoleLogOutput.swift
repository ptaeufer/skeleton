import Foundation

class ConsoleLogOutput: LogOutput {
    private(set) var level: Log.Level
    
    required init(level: Log.Level) {
        self.level = level
    }
    
    func log(_ logMessage: String, object: Any?, level: Log.Level, functionName: String, filePath: String, lineNumber: Int) {
        // log the message only if its internal level is less then given level
        guard level >= self.level else {
            return
        }
        
        let fileName = filePath.components(separatedBy: "/").last
        let time = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        
        var text = "\(time) [\(fileName ?? filePath):\(lineNumber)] \(functionName) > \(logMessage)"
        if let object = object {
            text.append("\n\(String(describing: object))")
        }
        print(text)
    }
}
