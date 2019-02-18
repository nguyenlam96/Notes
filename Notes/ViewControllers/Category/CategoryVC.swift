//
//  CategoryVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/14/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreData

class CategoryVC: UIViewController {
    
    // MARK: - Properties:
    var note: Note?
    var hasCategory: Bool {
        guard let fetchedObjects = self.fetchedResultsController.fetchedObjects else {
            LogUtils.LogDebug(type: .warning, message: "No fechedObjects")
            return false
        }
        return fetchedObjects.count > 0
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
       
        guard let managedObjectContext = self.note?.managedObjectContext else {
            LogUtils.LogDebug(type: .error, message: "managedObjectContext is nil")
            fatalError("managedObjectContext is nil")
        }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
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

        self.title = "Categories"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.setupBarButtonItem()
        self.fetchCategory()
        self.updateView()
    }
    
    deinit {
        print("CategoryVC is deinit")
    }
    
    // MARK: - Setup When ViewDidLoad:
    
    private func setupBarButtonItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButtonPressed))
    }
    
    @objc func handleAddButtonPressed() {
        performSegue(withIdentifier: "gotoAddCategoryVC", sender: self)
    }
    
    private func fetchCategory() {
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
            LogUtils.LogDebug(type: .error, message: "No identifier found")
            return
        }
        
        switch identifier {
        case "gotoAddCategoryVC":
            guard let desVC = segue.destination as? AddCategoryVC else {
                LogUtils.LogDebug(type: .error, message: "Can't get desVC")
                return
            }
            desVC.managedObjectContext = self.note?.managedObjectContext
            
        case "gotoEditCategoryVC":
            guard let desVC = segue.destination as? EditCategoryVC else {
                LogUtils.LogDebug(type: .error, message: "Can't get desVC")
                return
            }
            guard let cell = sender as? CategoryCell else {
                LogUtils.LogDebug(type: .error, message: "Can't get the tapped cell")
                return
            }
            guard let indexPath = self.tableView.indexPath(for: cell) else {
                LogUtils.LogDebug(type: .error, message: "indexPath is nil")
                return
            }

            let category = self.fetchedResultsController.object(at: indexPath)
            desVC.category = category
            desVC.managedObjectContext = self.note?.managedObjectContext
        default:
            break
        }
    }
    
    // MARK: - Helper Functions:
    private func updateView() {
        
        self.tableView.isHidden = !hasCategory
        self.messageLabel.isHidden = hasCategory
    }

}

extension CategoryVC: UITableViewDataSource, UITableViewDelegate {
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as! CategoryCell
        
        let category = self.fetchedResultsController.object(at: indexPath)
        cell.bindData(category: category)
        
        if note?.category == category {
            cell.nameLabel.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            cell.nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        } else {
            cell.nameLabel.textColor = .black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let category = self.fetchedResultsController.object(at: indexPath)
            self.note?.managedObjectContext?.delete(category)
        }
    }
    
    // MARK: - TableView Delegate:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        let category = self.fetchedResultsController.object(at: indexPath)
        self.note?.category = category
        
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension CategoryVC: NSFetchedResultsControllerDelegate {
    
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
                self.tableView.insertRows(at: [index], with: .fade)
            }
            break
        case .delete:
            if let index = indexPath {
                self.tableView.deleteRows(at: [index], with: .fade)
            }
            break
        case .move:
            if let sourceIndex = indexPath {
                self.tableView.deleteRows(at: [sourceIndex], with: .fade)
            }
            if let desIndex = newIndexPath {
                self.tableView.insertRows(at: [desIndex], with: .fade)
            }
            break
        case .update:
            // use indexPath for update
            if let index = indexPath {
                let updatedCategory = self.fetchedResultsController.object(at: index)
                let cell = self.tableView.cellForRow(at: index) as? CategoryCell
                cell?.bindData(category: updatedCategory)
            }
            break
        default:
            break
        }
    }
    
}
