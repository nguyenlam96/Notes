//
//  CoreDataManager.swift
//  Notes
//
//  Created by Nguyen Lam on 2/13/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import CoreData
import NotificationCenter

final class CoreDataManager {
    
    // MARK: - Properties:
    private let modelName: String
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managerObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        // managedObjectContext need to keep reference to the persistentStoreCoordinator:
            managerObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managerObjectContext
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        // helper:
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        // get URL:
        let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let persistentStoreURL = documentDirectoryURL?.appendingPathComponent(storeName)
        
        do {
            let options = [ NSMigratePersistentStoresAutomaticallyOption: true,
                            NSInferMappingModelAutomaticallyOption: true]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
        } catch {
            fatalError("Unable to add Persisten Store")
        }
        
        return persistentStoreCoordinator
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        
        guard let modelUrl = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to find model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Unable to load data model")
        }
        return managedObjectModel
    }()
    
    // MARK: - Initialization:
    init(modelName: String) {
        self.modelName = modelName
        self.setupNotificationHandling()
    }
    
    // MARK: - Setup:
    private func setupNotificationHandling() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func saveChanges() {
        
        // ensure there're changes:
        guard self.managedObjectContext.hasChanges else {
            LogUtils.LogDebug(type: .info, message: "There'is nothing changed")
            return
        }
        // save context:
        do {
            try self.managedObjectContext.save()
            LogUtils.LogDebug(type: .info, message: "=== saveContext!")
        } catch {
            LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
    }

    
    
}
