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
//    var coreDataManager: CoreDataManager = CoreDataManager(modelName: "Notes")
    private var persistentContainer = NSPersistentContainer(name: "Notes")
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "updatedAt", ascending: false) ]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    private var hasNotes: Bool {

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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
         
        self.title = "Notes"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.activityIndicatorView.startAnimating()
        self.persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            } else {
                self.activityIndicatorView.stopAnimating()
                LogUtils.LogDebug(type: .info, message: "activityIndicator is hidden")
                self.setupNotifications()
                self.fetchNotes()
                self.updateView()
            }
            
        }
        
       
    }
    
    
    // MARK: - Setup When ViewDidLoad:
    private func fetchNotes() {

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotiDashLineColorChanged(notification:)),
                                               name: NSNotification.Name(rawValue: NOTI_DASHLINE_COLOR_CHANGED),
                                               object: nil)
    }
    
    @objc func handleNotiDashLineColorChanged(notification: Notification) {
        LogUtils.LogDebug(type: .info, message: "\(#function) get called")

        guard let userInfo = notification.userInfo else {
            LogUtils.LogDebug(type: .warning, message: "UserInfo is nil")
            return
        }
        guard let updatedCategory = userInfo["category"] as? Category else {
            LogUtils.LogDebug(type: .info, message: "Can't find the category updated")
            return
        }

        var shouldUpdateDashLine = false
        var willUpdateNotes:[Note] = []
        
        guard let fetchedNotes = self.fetchedResultsController.fetchedObjects, fetchedNotes.count > 0 else {
            LogUtils.LogDebug(type: .warning, message: "fetchedNotes is nil or empty")
            return
        }
        for note in fetchedNotes {
            if note.category == updatedCategory {
                willUpdateNotes.append(note)
                shouldUpdateDashLine = true
            }
        }
        if shouldUpdateDashLine {
            shouldUpdateDashLine = false
            self.updateDashLine(of: willUpdateNotes)
        }


    }

    private func updateDashLine(of notes: [Note]) {
        LogUtils.LogDebug(type: .info, message: "\(#function) get called")
        // update at the cell that changed:
        for note in notes {
            if let index = self.fetchedResultsController.indexPath(forObject: note) {
                let cell = self.tableView.cellForRow(at: index) as? NoteCell
                cell?.bindData(note: note)
            } else {
                LogUtils.LogDebug(type: .info, message: "this index is nil")
            }
        }


    }
    // MARK: - IBAction:

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
            desVC.managedObjectContext = self.persistentContainer.viewContext
        case "gotoEditNoteVC":
            guard let desVC = segue.destination as? EditNoteVC else {
                LogUtils.LogDebug(type: .error, message: "desVC is nil")
                return
            }
            guard let indexPath = tableView.indexPathForSelectedRow else {
                LogUtils.LogDebug(type: .error, message: "indexPath is nil")
                return
            }
            let note = self.fetchedResultsController.object(at: indexPath)
            desVC.note = note
        case "gotoTagVC":
            guard let desVC = segue.destination as? TagVC else {
                LogUtils.LogDebug(type: .error, message: "desVC is nil")
                return
            }
            guard let tappedButton = sender as? UIButton else {
                LogUtils.LogDebug(type: .error, message: "can't get tapped button")
                return
            }
            let tappedButtonPosition: CGPoint = tappedButton.convert(CGPoint.zero, to: self.tableView)
            guard let indexPath = tableView.indexPathForRow(at: tappedButtonPosition) else {
                LogUtils.LogDebug(type: .error, message: "indexPath is nil")
                return
            }
            let note = self.fetchedResultsController.object(at: indexPath)
            desVC.note = note
        default:
            break
        }
    }
    
    // MARK: - Helper Functions:
    private func updateView() {
        
        self.tableView.isHidden = !hasNotes
        self.messageLabel.isHidden = hasNotes
    }
    
}

extension NoteVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableView Datasource:
    
    func numberOfSections(in tableView: UITableView) -> Int {

        guard let sections = self.fetchedResultsController.sections else {
            LogUtils.LogDebug(type: .error, message: "fetchedResultsController.section is nil")
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = self.fetchedResultsController.sections?[section] else {
            LogUtils.LogDebug(type: .error, message: "fetchedResultsController.section is nil")
            return 0
        }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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

        if editingStyle == .delete {
            let note = self.fetchedResultsController.object(at: indexPath)
            note.managedObjectContext?.delete(note)
            /// can use this too:
//            self.persistentContainer.viewContext.delete(note)
        }
    }
    // MARK: - TableView Delegate:
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension NoteVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView.endUpdates()
        self.updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        LogUtils.LogDebug(type: .info, message: "\(#function) get called")
        print("=== Type: \(type.rawValue)") /// 1: insert, 2: delete, 3: move, 4:update
        
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
            break
            // have to do this so the editedCell can move up to the top:
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
