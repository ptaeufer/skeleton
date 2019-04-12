import Foundation

class FileLogOutput: LogOutput {
    private(set) var level: Log.Level
    private(set) var outputFilePath: String?
    private var loggingQueue = DispatchQueue(label: "loggingQueue")
    
    required init(level: Log.Level) {
        self.level = level
        
        if let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let filePath = cacheUrl.appendingPathComponent("log").appendingPathExtension("txt").path
            
            if !FileManager.default.fileExists(atPath: filePath) {
                FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            }
            
            self.outputFilePath = filePath
        }
    }
    
    init(level: Log.Level, outputFilePath: String) {
        self.level = level
        self.outputFilePath = outputFilePath
        
        if !FileManager.default.fileExists(atPath: outputFilePath) {
            FileManager.default.createFile(atPath: outputFilePath, contents: nil, attributes: nil)
        }
    }
    
    func log(_ logMessage: String, object: Any?, level: Log.Level, functionName: String, filePath: String, lineNumber: Int) {
        loggingQueue.async {
            // log the message only if its internal level is less then given level
            guard level >= self.level else {
                return
            }
            
            let fileName = filePath.components(separatedBy: "/").last
            let time = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
            var text = "\(time) [\(fileName ?? filePath):\(lineNumber)] \(functionName) > \(logMessage)\n"
            if let object = object {
                text.append("\(String(describing: object))\n")
            }
            
            if let dataToWrite = text.data(using: .utf8), let path = self.outputFilePath {
                try? self.append(data: dataToWrite, to: path)
            }
        }
    }
    
    fileprivate func append(data: Data, to filePath: String) throws {
        if let fileHandle = FileHandle(forWritingAtPath: filePath) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
        else {
            if let url = URL(string: filePath) {
                try data.write(to: url, options: .atomic)
            }
        }
    }
}
