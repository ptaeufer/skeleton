import Foundation
import Promises

class Repository<T:Identifiable> : DataSource<T> {
    
    
    private var data = [String:T]()
    private var lastFetch = Date().date(byAddingMinutes: -5)
    private var currentState = R.event.not_initialized {
        didSet {
            self.notify(self.currentState)
        }
    }
    var state : R.event { return self.currentState }
    private var loadingPromise : Promise<[T]>?
    let datasources : [DataSource<T>]
    
    init(_ datasources : [DataSource<T>]) {
        self.datasources = datasources
        super.init()
        
        // Load repository on first use
        self.load().then { _ in }
    }
    
    func get(_ id : String) -> T? {
        return self.data[id]
    }
    
    @discardableResult func add(_ obj: T, for origin : Origin ) -> Result {
        self.data[obj.id] = obj
        self.datasources(for: origin).each { $1.add(obj) }
        notify(R.event.add(obj as Any))
        return .success
    }
    
    @discardableResult override func add(_ obj: T ) -> Result {
        self.data[obj.id] = obj
        datasources.each { $1.add(obj) }
        notify(R.event.add(obj as Any))
        return .success
    }
    
    
    @discardableResult override func delete(_ obj: T) -> Result {
        self.data.removeValue(forKey: obj.id)
        datasources.each { $1.delete(obj) }
        notify(R.event.delete(obj as Any))
        return .success
    }
    
    @discardableResult func delete(_ obj: T, for origin : Origin) -> Result {
        self.data.removeValue(forKey: obj.id)
        self.datasources(for: origin).each { $1.delete(obj) }
        notify(R.event.delete(obj as Any))
        return .success
    }
    
    @discardableResult override func delete(_ objects : [T]) -> Result {
        objects.forEach { self.data.removeValue(forKey: $0.id) }
        datasources.each { $1.delete(objects) }
        notify(R.event.deleteMany(objects as Any))
        return .success
    }
    
    @discardableResult override func update(_ obj: T) -> Result {
        data[obj.id] = obj
        datasources.each { $1.update(obj) }
        notify(R.event.update(obj as Any))
        return .success
    }
    
    @discardableResult func update(_ obj: T, for origin : Origin) -> Result {
        data[obj.id] = obj
        self.datasources(for: origin).each { $1.update(obj) }
        notify(R.event.update(obj as Any))
        return .success
    }
    
    
    @discardableResult override func clearAll() -> Result {
        self.data = [:]
        self.currentState = .not_initialized
        datasources.forEach { ds in
            ds.clearAll()
        }
        notify(R.event.deleteAll)
        return .success
    }
    

    
    override func list() -> [T] {
        if data.isEmpty {
            let syncDatasources = datasources.filter { !($0 is AsyncDataSource) }
            let allSynced = syncDatasources.flatMap{ $0.list() }
            allSynced.forEach {
                self.data[$0.id] = $0
            }
            return allSynced
        }
        return data.map({$0.value})
    }

    @discardableResult
    override func load() -> Promise<[T]> {
        if loadingPromise == nil {
            
            loadingPromise = Promise<[T]>(on : DispatchQueue.global(qos: .background)) { resolve, reject in
                DispatchQueue.main.async {
                    self.currentState = R.event.loading(self as AnyObject)
                }
                
                if Date() < self.lastFetch.date(byAddingMinutes: 1) {
                    resolve(self.list())
                    self.loadingPromise = nil
                    self.currentState = R.event.loaded(self as AnyObject)
                    return
                }
                all(self.datasources.map({$0.load()})).then { result in
                    result.each { _, entities in
                        entities.each { self.data[$1.id] = $1 }
                    }
                    resolve(self.list())
                    self.loadingPromise = nil
                    self.currentState = R.event.loaded(self as AnyObject)
                    self.lastFetch = Date()
                    }.catch { error in
                        self.loadingPromise = nil
                        self.currentState = R.event.error(self as AnyObject)
                        reject(error)

                }
            }
            
  
        }
        return loadingPromise!
    }
    
    override func register(_ observer: EventListener) {
        super.register(observer)
        notify(currentState)
    }
    
    func datasources(`for` origin : Origin) -> [DataSource<T>] {
        var ds = [DataSource<T>]()
        datasources.forEach {
            if $0.origin() == origin { ds.append($0) }
            if $0.origin() == .synced {
                if let _ds : [DataSource<T>] = ($0 as? Repository<T>)?.datasources(for : origin) {
                    _ds.forEach { ds.append($0) }
                }
            }
        }
        return ds
    }
}
