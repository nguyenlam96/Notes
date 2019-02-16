//
//  TagVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/15/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreData

class TagVC: UIViewController {
    
    // MARK: - Properties:
    var note: Note?
    
    private var hasTag: Bool {
        guard let fetchedObjects = self.fetchedResultsController.fetchedObjects else {
            LogUtils.LogDebug(type: .warning, message: "No fechedObjects")
            return false
        }
        return fetchedObjects.count > 0
    }

    private lazy var fetchedResultsController: NSFetchedResultsController<Tag> = {
        
        guard let note = self.note else {
            LogUtils.LogDebug(type: .error, message: "note is nil")
            fatalError("note is nil")
        }
        guard let managedObjectContext = self.note?.managedObjectContext else {
            LogUtils.LogDebug(type: .error, message: "managedObjectContext is nil")
            fatalError("managedObjectContext is nil")
        }
        
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - IBOutlet:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.fetchTags()
        self.updateTableView()
        self.setupBarButtonItem()
    }
    
    deinit {
        print("=== TagVC is deinit")
    }
    
    // MARK: - Setup When ViewDidLoad:
    private func setupBarButtonItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButtonPressed))
    }
    
    @objc func handleAddButtonPressed() {
        performSegue(withIdentifier: "gotoAddTagVC", sender: self)
    }
    
    private func fetchTags() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
    }
    
    // MARK: Navigation:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            LogUtils.LogDebug(type: .error, message: "Can't get identifier")
            return
        }
        switch identifier {
        case "gotoAddTagVC":
            guard let desVC = segue.destination as? AddTagVC else {
                LogUtils.LogDebug(type: .error, message: "can't get desVC")
                return
            }
            desVC.managedObjectContext = self.note?.managedObjectContext
        case "gotoEditTagVC":
            guard let desVC = segue.destination as? EditTagVC else {
                LogUtils.LogDebug(type: .error, message: "can't get desVC")
                return
            }
            guard let cell = sender as? TagCell else {
                LogUtils.LogDebug(type: .error, message: "can't get cell")
                return
            }
            guard let index = self.tableView.indexPath(for: cell) else {
                LogUtils.LogDebug(type: .error, message: "can't get index")
                return
            }
            let tag = self.fetchedResultsController.object(at: index)
            desVC.tag = tag
        default:
            break
        }
    }
    
    // MARK: - Helper Functions:
    private func updateTableView() {
        self.tableView.isHidden = !hasTag
        self.messageLabel.isHidden = hasTag
    }
 
}

extension TagVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableView Datasource:
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = self.fetchedResultsController.sections else {
            LogUtils.LogDebug(type: .warning, message: "sections is nil")
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = self.fetchedResultsController.sections?[section] else {
            LogUtils.LogDebug(type: .warning, message: "section is nil")
            return 0
        }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TagCell.reuseIdentifier, for: indexPath) as! TagCell
        let tag = self.fetchedResultsController.object(at: indexPath)
        
        if let containsTag = note?.tags?.contains(tag) {
            cell.tagNameLabel.textColor = (containsTag) ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : .black
        }
        
        cell.bindData(with: tag)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let tag = self.fetchedResultsController.object(at: indexPath)
            self.note?.managedObjectContext?.delete(tag)
        }
    }
    
    // MARK: - TableView Delegate:
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        // fetch tag:
        let tag = self.fetchedResultsController.object(at: indexPath)
        if (self.note?.tags?.contains(tag))! {
            // remove it
            self.note?.removeFromTags(tag)
        } else {
            // add it
            self.note?.addToTags(tag)
        }
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension TagVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.updateTableView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        LogUtils.LogDebug(type: .info, message: "\(#function) get called")
        print("=== Type: \(type.rawValue)") /// 1: insert, 2: delete, 3: move, 4:update
        
        switch type {
        case .insert:
            if let index = newIndexPath {
                self.tableView.insertRows(at: [index], with: .fade)
            }
        case .delete:
            if let index = indexPath {
                self.tableView.deleteRows(at: [index], with: .fade)
            }
        case .update:
            if let index = newIndexPath {
                let updatedTag = self.fetchedResultsController.object(at: index)
                let cell = self.tableView.cellForRow(at: index) as? TagCell
                cell?.bindData(with: updatedTag)
            }
        case .move:
            // have to do this so the editedCell can move up to the top:
            if let sourceIndex = indexPath {
                self.tableView.deleteRows(at: [sourceIndex], with: .fade)
            }
            if let desIndex = newIndexPath {
                self.tableView.insertRows(at: [desIndex], with: .fade)
            }
            break
        default:
            break
        }
    }
    
}
