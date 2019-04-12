import Foundation
import CoreData

class CoreDataStack {

    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }
    
    func saveViewContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Public
    func viewContextItems<T: NSManagedObject>(matching predicate: NSPredicate) -> [T] {
        let results: [T] = T.all(in: persistentContainer.viewContext, matching: predicate)
        return results
    }
    
    func items<T: NSManagedObject>(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> [T] {
        let results: [T] = T.all(in: context, matching: predicate)
        return results
    }
    
    func clearAllCoreData() {
        let entities = self.persistentContainer.managedObjectModel.entities
        entities.compactMap({ $0.name }).forEach(clearDeepObjectEntity)
    }
    
    private func clearDeepObjectEntity(_ entity: String) {
        let context = self.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        let _ = try? context.execute(deleteRequest)
        try? context.save()
    }
}

extension CoreDataStack {
    class func persistentStorage() -> CoreDataStack {
        let container = NSPersistentContainer(name: "DataBase")
        
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("DataBase.sqlite")
        let description = NSPersistentStoreDescription(url: url)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        let storage = CoreDataStack(container: container)
        return storage
    }
}
