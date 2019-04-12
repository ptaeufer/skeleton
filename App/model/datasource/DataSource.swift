import Foundation
import Promises

enum Origin {
    case local, remote, synced
}

class DataSource<T:Identifiable> : Observable{
    enum Result {
        case success, error(Error)
    }

    @discardableResult func add(_ obj : T) -> Result { fatalError("must be overwritten") }
    @discardableResult func delete(_ obj : T) -> Result { fatalError("must be overwritten") }
    @discardableResult func delete(_ objects : [T]) -> Result { fatalError("must be overwritten") }
    @discardableResult func clearAll() -> Result { fatalError("must be overwritten") }
    @discardableResult func update(_ obj : T) -> Result { fatalError("must be overwritten") }
    func list() -> [T] { fatalError("must be overwritten") }
    func load() -> Promise<[T]> { fatalError("must be overwritten") }
    func origin() -> Origin { fatalError("must be overwritten") }
}

class AsyncDataSource<T:Identifiable>: DataSource<T> {

    func add(_ obj: T) -> Promise<Result> { fatalError("must be overwritten") }
    func delete(_ obj : T) -> Promise<Result> { fatalError("must be overwritten") }
    func delete(_ objects : [T]) -> Promise<Result> { fatalError("must be overwritten") }
    func update(_ obj : T) -> Promise<Result> { fatalError("must be overwritten") }

}


