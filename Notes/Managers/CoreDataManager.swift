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
    
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        
        let mainManagerObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            mainManagerObjectContext.parent = self.privateManagedObjectContext
        
        return mainManagerObjectContext
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return privateManagedObjectContext
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
        
        // push changes to privateContext:
        self.mainManagedObjectContext.performAndWait {
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save() /// changes will be pushed to the privateManagedObjectContext, it's sync to ensure that the changes are really pushed to the privateManagedObjectContext
                    LogUtils.LogDebug(type: .info, message: "=== pushed change to privateManagedObjectContext!")
                }
            } catch let saveError {
                LogUtils.LogDebug(type: .error, message: "Fail to save on mainManagedObjectContext: \(saveError.localizedDescription)")
                return
            }
        }
        // save changes:
        self.privateManagedObjectContext.perform {
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save() /// actually talk to persistenStoreCoordinator to write to persistenStore, it's async to perform immediately
                    LogUtils.LogDebug(type: .info, message: "=== saved changes to persistenStore!")
                }
            } catch let saveError {
                LogUtils.LogDebug(type: .error, message: "Fail to save on privateManagedObjectContext: \(saveError.localizedDescription)")
                return
            }
        }
        
    }

    
    
}
