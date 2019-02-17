////
////  CustomPersistentContainer.swift
////  Notes
////
////  Created by Nguyen Lam on 2/17/19.
////  Copyright © 2019 Nguyen Lam. All rights reserved.
////
//
//import Foundation
//import CoreData
//import NotificationCenter
//
//class CustomerPersistentContainer: NSPersistentContainer {
//    
//    // MARK: - Initialization:
//    init(modelName: String) {
//        self.modelName = modelName
//        self.setupNotificationHandling()
//    }
//    
//    // MARK: - Setup:
//    private func setupNotificationHandling() {
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges), name: UIApplication.willTerminateNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges), name: UIApplication.didEnterBackgroundNotification, object: nil)
//    }
//    
//    @objc func saveChanges() {
//        
//        self.mainManagedObjectContext.performAndWait {
//            do {
//                if self.mainManagedObjectContext.hasChanges {
//                    try self.mainManagedObjectContext.save() /// changes will be pushed to the privateManagedObjectContext ( the parent ), it's sync to ensure that the changes are really pushed to the privateManagedObjectContext
//                    LogUtils.LogDebug(type: .info, message: "=== pushed change to privateManagedObjectContext!")
//                }
//            } catch let saveError {
//                LogUtils.LogDebug(type: .error, message: "Fail to save on mainManagedObjectContext: \(saveError.localizedDescription)")
//                return
//            }
//        }
//        self.privateManagedObjectContext.perform {
//            do {
//                if self.privateManagedObjectContext.hasChanges {
//                    try self.privateManagedObjectContext.save() /// actually talk to persistenStoreCoordinator to write to persistenStore, it's async to perform immediately
//                    LogUtils.LogDebug(type: .info, message: "=== saved changes to persistenStore!")
//                }
//            } catch let saveError {
//                LogUtils.LogDebug(type: .error, message: "Fail to save on privateManagedObjectContext: \(saveError.localizedDescription)")
//                return
//            }
//        }
//    
//    
//}
