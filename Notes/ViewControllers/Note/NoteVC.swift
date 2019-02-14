//
//  ViewController.swift
//  Notes
//
//  Created by Nguyen Lam on 2/13/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreData

class NoteVC: UIViewController {

    // MARK: - Properties:
    var coreDataManager: CoreDataManager = CoreDataManager(modelName: "Notes")
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "updatedAt", ascending: false) ]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    private var notes: [Note]? {
        didSet {
            updateTableView()
        }
    }
    
    private var hasNotes: Bool {
//        guard self.notes != nil else {
//            LogUtils.LogDebug(type: .error, message: "notes is nil")
//            return false
//        }
//        return self.notes!.count > 0
        guard let fetchedObjects = self.fetchedResultsController.fetchedObjects else {
            LogUtils.LogDebug(type: .error, message: "notes is nil")
            return false
        }
        return fetchedObjects.count > 0
    }
    
    private var notesDidChange = false
    
    // MARK: - IBOutlet:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Notes"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.fetchNotes()
//        self.setupNotificationHandling()
        self.updateTableView()
    }
    
    
    // MARK: - Setup When ViewDidLoad:
    private func fetchNotes() {
        
//        // define fetch request:
//        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
//        let dateSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
//        fetchRequest.sortDescriptors = [ dateSortDescriptor ]
//        // perform fetch request:
//        self.coreDataManager.managedObjectContext.performAndWait {
//            do {
//                let fetchedNotes = try fetchRequest.execute()
//                self.notes = fetchedNotes
//                self.tableView.reloadData()
//            } catch {
//                LogUtils.LogDebug(type: .error, message: error.localizedDescription)
//                return
//            }
//        }
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
    }
    
    private func setupNotificationHandling() {
        // this notification is used to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidChange(notification:)),
                                            name: .NSManagedObjectContextObjectsDidChange,
                                            object: self.coreDataManager.managedObjectContext)
    }
    
    @objc func managedObjectContextDidChange(notification: Notification) {
        LogUtils.LogDebug(type: .info, message: "Detect that there's some objects changed")
        // ensure there're notes changed:
        guard let userInfo = notification.userInfo else {
            LogUtils.LogDebug(type: .warning, message: "UserInfo is nil")
            return
        }
        // it's insert changes:
        if let insertedObjects = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            
            LogUtils.LogDebug(type: .warning, message: "it's insert changes")
            for insertedObject in insertedObjects {
                if let insertedNote = insertedObject as? Note {
                    self.notes?.append(insertedNote)
                    self.notesDidChange = true
                }
            }
        }
        // it's update changes:
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            
            LogUtils.LogDebug(type: .info, message: "it's update changes")
            for updatedObject in updatedObjects {
                if let _ = updatedObject as? Note {
                    self.notesDidChange = true
                }
            }
        }
        // it's delete changes:
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            
            LogUtils.LogDebug(type: .info, message: "it's delete changes")
            for deletedObject in deletedObjects {
                if let deletedNote = deletedObject as? Note {
                    if let index = self.notes?.index(of: deletedNote) {
                        self.notes?.remove(at: index)
                        self.notesDidChange = true
                    } else {
                        LogUtils.LogDebug(type: .error, message: "Can't find index of deletedNote: \(deletedNote)")
                    }
                }
            }
        }
        // update table view:
        if notesDidChange {
            // re-sort by date:
            self.notes?.sort(by: { (note1, note2) -> Bool in
                note1.updatedAtAsDate > note2.updatedAtAsDate
            })
            // reload tbview:
            self.tableView.reloadData()
            self.updateTableView() // updateTableView() do the work of show/hidden messageLabel when there's tableView is empty
            self.notesDidChange = false
            LogUtils.LogDebug(type: .info, message: "=== TableView has updated!")
        }
    }
    
    // MARK: - IBAction:
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        self.navigationItem.leftBarButtonItem?.title = (self.tableView.isEditing) ? "Edit" : "Done"
        self.tableView.isEditing = !self.tableView.isEditing
    }
    
    // MARK: Navigation:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            LogUtils.LogDebug(type: .error, message: "segue identifier is nil")
            return
        }
        switch identifier {
        case "gotoAddNoteVC":
            guard let desVC = segue.destination as? AddNoteVC else {
                LogUtils.LogDebug(type: .error, message: "desVC is nil")
                return
            }
            desVC.managedObjectContext = self.coreDataManager.managedObjectContext
        case "gotoEditNoteVC":
            guard let desVC = segue.destination as? EditNoteVC else {
                LogUtils.LogDebug(type: .error, message: "desVC is nil")
                return
            }
//            guard let indexPath = tableView.indexPathForSelectedRow, let note = self.notes?[indexPath.row] else {
//                LogUtils.LogDebug(type: .error, message: "Can't get the note at indexPath")
//                return
//            }
            guard let indexPath = tableView.indexPathForSelectedRow else {
                LogUtils.LogDebug(type: .error, message: "this indexPath is nil")
                return
            }
            let note = self.fetchedResultsController.object(at: indexPath)
            desVC.note = note
        default:
            break
        }
    }
    
    // MARK: - Helper Functions:
    private func updateTableView() {
        
        self.tableView.isHidden = !hasNotes
        self.messageLabel.isHidden = hasNotes
    }
    
}

extension NoteVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableView Datasource:
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return hasNotes ? 1 : 0
        guard let section = self.fetchedResultsController.sections else {
            LogUtils.LogDebug(type: .error, message: "fetchedResultsController.section is nil")
            return 0
        }
        return section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return hasNotes ? self.notes!.count : 0
        guard let section = self.fetchedResultsController.sections?[section] else {
            LogUtils.LogDebug(type: .error, message: "fetchedResultsController.section is nil")
            return 0
        }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.reuseIdentifier, for: indexPath) as? NoteCell else {
//            fatalError("Unexpected Indexpath")
//        }
//        guard let note = self.notes?[indexPath.row] else {
//            LogUtils.LogDebug(type: .error, message: "Fail to get note")
//            return tableView.dequeueReusableCell(withIdentifier: "Cell")!
//        }
//        // bind data:
//        cell.bindData(note: note)
//
//        return cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.reuseIdentifier, for: indexPath) as? NoteCell else {
            fatalError("Unexpected Indexpath")
        }
        let note = self.fetchedResultsController.object(at: indexPath)
        cell.bindData(note: note)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
//        if editingStyle == .delete {
//            // ensure there's a note:
//            guard let note = self.notes?[indexPath.row] else {
//                LogUtils.LogDebug(type: .error, message: "can't get the note from indexPath")
//                return
//            }
//            // the delete it:
//            note.managedObjectContext?.delete(note)
////            self.coreDataManager.managedObjectContext.delete(note) // this line works too
//        }
        if editingStyle == .delete {
            let note = self.fetchedResultsController.object(at: indexPath)
            note.managedObjectContext?.delete(note)
        }
        
        
    }
    // MARK: - TableView Delegate:
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        
        
        
    }
    
}

extension NoteVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        // inform the tableView that updates are on their way:
        self.tableView.beginUpdates()
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView.endUpdates()
        self.updateTableView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let index = newIndexPath {
                self.tableView.insertRows(at: [index], with: UITableView.RowAnimation.fade)
            }
        case .delete:
            if let index = indexPath {
                self.tableView.deleteRows(at: [index], with: UITableView.RowAnimation.fade)
            }
        case .update:
            // update at the cell that changed:
            if let index = newIndexPath {
                let note = self.fetchedResultsController.object(at: index)
                let cell = self.tableView.cellForRow(at: index) as? NoteCell
                cell?.bindData(note: note)
            }
        case .move:
            if let sourceIndex = indexPath {
                self.tableView.deleteRows(at: [sourceIndex], with: .fade)
            }
            if let desIndex = newIndexPath {
                self.tableView.insertRows(at: [desIndex], with: .fade)
            }
        default:
            break
        }
    }
}
