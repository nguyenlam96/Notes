//
//  EditCategoryVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/14/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreData

class EditCategoryVC: UIViewController {
    
    // MARK: - Properties:
    var managedObjectContext: NSManagedObjectContext?
    var category: Category?
    private var currentCategoryName = ""
    
    // MARK: - Properties:
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Category"
        self.setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        guard let _ = self.managedObjectContext else {
            LogUtils.LogDebug(type: .error, message: "managedObjectConText is nil")
            return
        }
        guard let category = self.category else {
            LogUtils.LogDebug(type: .error, message: "category is nil")
            return
        }
        guard let editedName = self.categoryNameTextField.text, (editedName != self.currentCategoryName) else {
            LogUtils.LogDebug(type: .error, message: "There's nothing changes")
            return
        }
        // do change:
        category.name = editedName
        /* save updatedCategory to persistentStore will be executed when the app's going to be terminated or go to the background (using notification) */
    }
    
    deinit {
        print("EditCategoryVC is deinit")
    }

    // MARK: - Setup When ViewDidLoad:
    private func setupView() {
        self.categoryNameTextField.text = self.category?.name
        self.currentCategoryName = (self.category?.name)!
    }
    

}
