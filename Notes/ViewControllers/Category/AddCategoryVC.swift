//
//  AddCategoryVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/14/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreData

class AddCategoryVC: UIViewController {

    // MARK: - Properties:
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - IBOutlet:
    @IBOutlet weak var nameTextField: UITextField!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Category"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveCategory))
    }
    
    deinit {
        print("AddCategoryVC is deinit")
    }

    // MARK: - Setup When ViewDidLoad:
    @objc func saveCategory() {
        // ensure managedObjectContext exist
        guard let managedObjectContext = self.managedObjectContext else {
            LogUtils.LogDebug(type: .error, message: "managedObjectContext is nil")
            return
        }
        // ensure category's name is not empty:
        guard let categoryName = self.nameTextField.text, categoryName.count > 0 else {
            self.showAlert(title: "CategoryName is empty", message: "Please enter category name")
            return
        }
        // create category;
        let newCategory = Category(context: managedObjectContext)
            newCategory.name = categoryName
        
        self.navigationController?.popViewController(animated: true)
    }

}
