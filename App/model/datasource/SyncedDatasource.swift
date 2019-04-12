import Foundation
import Promises

class SyncOperation<T:Identifiable & Codable>: Identifiable & Codable {
    let id : String
    let obj : T
    let action : String
    let dataSource : Int
    let createdAt : Date

    init(id : String,
        obj : T,
        action : String,
        dataSource : Int,
        createdAt : Date)
    {
        self.id = id
        self.action = action
        self.obj = obj
        self.dataSource = dataSource
        self.createdAt = createdAt
    }
    
}

class SyncedDatasource<T : Identifiable & Codable>: Repository<T> {
   
    private let internalStore = KeychainDataSource<SyncOperation<T>>()
    private var timer : Timer?
    private var loadingPromise : Promise<[T]>?
    
    override func origin() -> Origin {
        return .synced
    }
    
    @objc private func process() {
        timer?.invalidate()

        func processResult(_ result : Result, operation : SyncOperation<T>) {
            // TODO : proper error handling
            switch result {
                case .success : self.internalStore.delete(operation)
                case .error : self.internalStore.update(operation)
            }
        }
        
        internalStore.list().sorted(by: { $0.createdAt < $1.createdAt }).each { index,operation in
            switch operation.action {
            case R.event.datasource_add.plainEvent.rawValue:
                if let ds = self.datasources[operation.dataSource] as? AsyncDataSource {
                    ds.add(operation.obj).then { result in
                        processResult(result, operation: operation)
                    }
                } else {
                    processResult(self.datasources[operation.dataSource].add(operation.obj), operation: operation)
                }
            case R.event.datasource_update.plainEvent.rawValue:
                if let ds = self.datasources[operation.dataSource] as? AsyncDataSource {
                    ds.update(operation.obj).then { result in
                        processResult(result, operation: operation)
                    }
                } else {
                    processResult(self.datasources[operation.dataSource].update(operation.obj), operation: operation)
                }
            case R.event.datasource_delete.plainEvent.rawValue:
                if let ds = self.datasources[operation.dataSource] as? AsyncDataSource {
                    ds.delete(operation.obj).then { result in
                        processResult(result, operation: operation)
                    }
                } else {
                    processResult(self.datasources[operation.dataSource].delete(operation.obj), operation: operation)
                }
            default : break
            }
        }

        
        if !internalStore.list().isEmpty {
            //timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(process), userInfo: nil, repeats: true)
        }
        
    }
    
    func processResult(_ result : Result, operation : SyncOperation<T>) {
        // TODO : proper error handling
        switch result {
        case .success : self.internalStore.delete(operation)
        case .error : self.internalStore.update(operation)
        }
    }
    
    @discardableResult override func add(_ obj: T) -> Result {
        self.datasources.forEach { $0.add(obj) }
        
        /*
        add(operation: R.event.datasource_add, for: obj)
        self.process()*/
        return .success
    }

    
    @discardableResult override func delete(_ obj: T) -> Result{
        self.datasources.forEach { $0.delete(obj) }
        /*
        add(operation: R.event.datasource_delete, for: obj)
        self.process()*/
        return .success
    }
    
    @discardableResult override func update(_ obj: T) -> Result {
        self.datasources.forEach { $0.update(obj) }
        /*
        add(operation: R.event.datasource_update, for: obj)
        self.process()*/
        return .success
    }
    
    private func add(operation : R.event, for obj : T) {
        datasources.each {index, ds in
            internalStore.add(
                SyncOperation(
                    id: UUID().uuidString,
                    obj : obj,
                    action: operation.plainEvent.rawValue,
                    dataSource : index,
                    createdAt : Date()
                )
            )
        }
    }
    
    
    /*
     Load all datasources
     merge queue operations on results
     add differences to other datasources
     */
    override func load() -> Promise<[T]> {
        if loadingPromise == nil {
            loadingPromise = Promise<[T]> { resolve, reject in
                all(self.datasources.map({$0.load()})).then { results in
                    var dataSets = [[String:T]]()
                    results.each { index, result in
                        var data = [String:T]()
                        result.each { data[$1.id] = $1 }
                        self.internalStore.list().filter({$0.dataSource == index}).sorted(by: { $0.createdAt < $1.createdAt }).each { _, operation in
                            switch operation.action {
                            case R.event.datasource_add.plainEvent.rawValue, R.event.datasource_update.plainEvent.rawValue: data[operation.obj.id] = operation.obj
                            case R.event.datasource_delete.plainEvent.rawValue: data.removeValue(forKey: operation.obj.id)
                            default : break
                            }
                        }
                        dataSets.insert(data, at: index)
                    }
                    var mergedSet : [String:T]?
                    dataSets.each { index,dataSet in
                        if mergedSet == nil {
                            mergedSet = dataSet
                        } else {
                            mergedSet!.merge(dataSet) { (_, new) in new }
                        }
                    }
                    
                    mergedSet?.each { _, el in
                        dataSets.each { index,dataSet in
                            if dataSet[el.key] == nil {
                                self.datasources[index].add(el.value)
                            }
                        }
                    }
                    self.loadingPromise = nil
                    resolve(mergedSet!.values.map({$0}))
                    }.catch {
                        self.loadingPromise = nil
                        reject($0)
                }
            }
        }
        
        return loadingPromise!
        
    }


}
