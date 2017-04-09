/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Singleton controller to manage the main Core Data stack for the application. It vends a persistent store coordinator, the managed object model, and a URL for the persistent store.
*/

import CoreData

class CoreDataStackManager {
    // MARK: Properties
    var t = 0
    static let sharedManager = CoreDataStackManager()
    
    static let mainStoreFileName = "CoreData.sqlite"
    static let cordinator = "CoreData"
    
    static let errorDomain = "CoreDataStackManager"

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Initialization
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSavePrivateQueueContext(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.privateQueueCtxt)
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSaveMainQueueContext(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.mainQueueCtxt)
    }
    
    // MARK: - Notifications
    
    @objc func contextDidSavePrivateQueueContext(_ notification: Notification) {
        if let context = self.mainQueueCtxt {
            self.synced(self, closure: { () -> () in
                context.perform({() -> Void in
                    context.mergeChanges(fromContextDidSave: notification)
                })
            })
        }
    }
    
    @objc func contextDidSaveMainQueueContext(_ notification: Notification) {
        if let context = self.privateQueueCtxt {
            self.synced(self, closure: { () -> () in
                context.perform({() -> Void in
                    context.mergeChanges(fromContextDidSave: notification)
                })
            })
        }
    }
    
    func synced(_ lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named 'Bundle identifier' in the application's documents Application Support directory.
        let urls = Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: cordinator, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        let directory = SGConst.groupURL
        let url = directory.appendingPathComponent(mainStoreFileName)
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch var error as NSError {
            coordinator = nil
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        return coordinator
    }()
    
    // MARK: - NSManagedObject Contexts
    
    open class func mainQueueContext() -> NSManagedObjectContext {
        return self.sharedManager.mainQueueCtxt!
    }
    
    open class func privateQueueContext() -> NSManagedObjectContext {
        return self.sharedManager.privateQueueCtxt!
    }
    
    lazy var mainQueueCtxt: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        var managedObjectContext = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    lazy var privateQueueCtxt: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        var managedObjectContext = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support
    
    public class func saveContext(context: NSManagedObjectContext?) {
        if let moc = context {
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch {
                }
            }
        }
    }
    
    func deleteDocumentsResources() {
        let request = NSFetchRequest<SGDocument>(entityName: "SGDocument")
        let documents = try? mainQueueCtxt?.fetch(request)
        documents??.enumerated().forEach() {
            $1.deleteDocumentsResource()
        }
        
    }
    
    func clearCoreDataStore() {
        let entities = managedObjectModel.entities
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            let deleteReqest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try mainQueueCtxt?.execute(deleteReqest)
            } catch {
                print(error)
            }
        }
    }
}
