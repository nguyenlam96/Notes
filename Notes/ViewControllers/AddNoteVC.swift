//
//  AddNoteVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/13/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreData

class AddNoteVC: UIViewController {
    
    // MARK: - Properties:
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            LogUtils.LogDebug(type: .info, message: "\(String(describing: managedObjectContext?.description))")
        }
    }
    
    // MARK: - IBOutlet:
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Note"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
    }
    deinit {
        print("=== AddNoteVC is deinit")
    }
    
    // MARK: - Private Funcs:
    @objc func save() {
        
        // ensure having managedObjectContext:
        guard let managedObjectContext = self.managedObjectContext else {
            LogUtils.LogDebug(type: .error, message: "managedObjectContext is nil")
            return
        }
        // ensure title isn't empty:
        guard let title = self.titleTextField.text, !title.isEmpty else {
            self.showAlert(title: "Title is empty", message: "Please enter title")
            return
        }
        // create Note:
        let newNote = Note(context: managedObjectContext)
            newNote.createdAt = Date()
            newNote.updatedAt = Date()
            newNote.title = title
            newNote.content = self.contentTextView.text
        /* the save newNote to persistentStore will be executed when the app's going to be terminated or go to the background (using notification) */
        
        // pop out of navigation stack:
        self.navigationController?.popViewController(animated: true)
        
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
