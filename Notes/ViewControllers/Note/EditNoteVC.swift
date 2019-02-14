//
//  EditNoteVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/13/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class EditNoteVC: UIViewController {
    
    // MARK: - Properties:
    var note: Note? {
        didSet {
            LogUtils.LogDebug(type: .info, message: "Load note successfully")
        }
    }
    // MARK: - IBOutlet:
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Note"
        self.setupView()
    }
    deinit {
        print("=== EditNoteVC is deinit")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    // update data at the moment view disappear:
        
        // ensure title is not empty
        guard let editedTitle = self.titleLabel.text, !editedTitle.isEmpty else {
            showAlert(title: "Title is empty", message: "Please enter the title")
            return
        }
        // update note:
        self.note?.updatedAt = Date()
        self.note?.title = editedTitle
        self.note?.content = self.contentTextView.text
        /* update newNote to persistentStore will be executed when the app's going to be terminated or go to the background (using notification) */
    }
    
    // MARK: Navigation:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            LogUtils.LogDebug(type: .error, message: "identifier not found")
            return
        }
        switch identifier {
        case "gotoCategoryVC":
            guard let desVC = segue.destination as? CategoryVC else {
                LogUtils.LogDebug(type: .error, message: "desVC not found")
                return
            }
            desVC.note = self.note
        default:
            break
        }
    }
    
    // MARK: - Helper Functions:
    private func setupView() {
        
        setupTitleTextField()
        setupContentTextView()
    }
    
    private func setupTitleTextField() {
        
        self.titleLabel.text = self.note?.title
    }
    
    private func setupContentTextView() {
        
        self.contentTextView.text = self.note?.content
    }
    
    
  
    
}
