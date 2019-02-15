//
//  AddTagVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/15/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreData

class AddTagVC: UIViewController {

    // MARK: - Properties:
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - IBOutlet:
    @IBOutlet weak var tagNameTextField: UITextField!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Tag"
        self.setupBarButtonItem()
    }
    
    deinit {
        print("=== AddTagVC is deinit")
    }
    
    // MARK: - Setup When ViewDidLoad:
    private func setupBarButtonItem() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSaveButtonPressed))
    }
    @objc func handleSaveButtonPressed() {
        
        guard let managedObjectContext = self.managedObjectContext else {
            LogUtils.LogDebug(type: .error, message: "managedObjectContext is nil")
            return
        }
        guard let tagName = self.tagNameTextField.text, tagName.count > 0 else {
            self.showAlert(title: "TagName is empty", message: "Please enter tagname")
            return
        }
        print("=== Do add Tag")
        let newTag = Tag(context: managedObjectContext)
            newTag.name = tagName
        self.navigationController?.popViewController(animated: true)
    }


}
