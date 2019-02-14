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
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
       
        guard let managedObjectContext = self.note?.managedObjectContext else {
            LogUtils.LogDebug(type: .error, message: "managedObjectContext is nil")
            fatalError("managedObjectContext is nil")
        }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "updatedAt", ascending: false) ]
        
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
            desVC.managedObjectContext = self.note?.managedObjectContext
        default:
            break
        }
    }

}

extension CategoryVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableView Datasource:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
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
    
    
    
}

extension CategoryVC: NSFetchedResultsControllerDelegate {
    
}
