import Foundation

/// Defines outputs for logging with required initializer and log method
protocol LogOutput: class {
    init(level: Log.Level)
    func log(_ logMessage: String, object: Any?, level: Log.Level, functionName: String, filePath: String, lineNumber: Int)
    
    var level: Log.Level { get }
}

/// Allows to log text information to the output like console or file.
class Log {
    enum Level: String {
        case verbose = "VERBOSE"
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
    
        static func >=(a: Level, b: Level) -> Bool {
            let levels: [Level] = [.verbose, .debug, .info, .warning, .error]
            if let indexA = levels.index(of: a), let indexB = levels.index(of: b) {
                return indexA >= indexB
            }
            return false
        }
    }
    
    // MARK: - Outputs configuration
    
    /// Subscribes the output to receive logging messages
    ///
    /// - parameter output: Output
    class func addOutput(_ output: LogOutput) {
        outputs.append(output)
    }
    
    
    /// Removes the given output so it won't receive log messages anymore
    ///
    /// - parameter output: Output
    class func removeOutput(_ output: LogOutput) {
        if let index = outputs.index(where: { $0 === output }) {
            outputs.remove(at: index)
        }
    }
    
    /// Removes all the outputs from logging
    class func removeAllOutputs() {
        outputs.removeAll()
    }
    
    /// Returns all current outputs
    static var currentOutputs: [LogOutput] {
        return outputs
    }
    
    // MARK: - Logging methods
    class func verbose(_ verboseMessage: String, object: Any? = nil, functionName: String = #function, filePath: String = #file, lineNumber: Int = #line) {
        outputs.forEach { $0.log(verboseMessage, object: object, level: .verbose, functionName: functionName, filePath: filePath, lineNumber: lineNumber) }
    }
    
    class func debug(_ debugMessage: String, object: Any? = nil, functionName: String = #function, filePath: String = #file, lineNumber: Int = #line) {
        outputs.forEach { $0.log(debugMessage, object: object, level: .debug, functionName: functionName, filePath: filePath, lineNumber: lineNumber) }
    }
    
    class func info(_ infoMessage: String, object: Any? = nil, functionName: String = #function, filePath: String = #file, lineNumber: Int = #line) {
        outputs.forEach { $0.log(infoMessage, object: object, level: .info, functionName: functionName, filePath: filePath, lineNumber: lineNumber) }
    }
    
    class func warning(_ warningMessage: String, object: Any? = nil, functionName: String = #function, filePath: String = #file, lineNumber: Int = #line) {
        outputs.forEach { $0.log(warningMessage, object: object, level: .warning, functionName: functionName, filePath: filePath, lineNumber: lineNumber) }
    }
    
    class func error(_ errorMessage: String, object: Any? = nil, functionName: String = #function, filePath: String = #file, lineNumber: Int = #line) {
        outputs.forEach { $0.log(errorMessage, object: object, level: .error, functionName: functionName, filePath: filePath, lineNumber: lineNumber) }
    }
    
    // MARK: - Private
    fileprivate static var outputs: [LogOutput] = []
}
