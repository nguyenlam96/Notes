//
//  EditNoteVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/13/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreData

class EditNoteVC: UIViewController {
    
    // MARK: - Properties:
    var note: Note?
    private var currentTitleValue = ""
    private var currentContentValue = ""
    private var currentCategoryValue = ""
    // MARK: - IBOutlet:
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Note"
        self.setupView()
        self.setupNotificationHandling()
    }
    deinit {
        print("=== EditNoteVC is deinit")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    
        // update data at the moment view disappear:
        guard let editedTitle = self.titleTextField.text, !editedTitle.isEmpty else {
            showAlert(title: "Title is empty", message: "Please enter the title")
            return
        }
        let editedContent = self.contentTextView.text
        guard (editedTitle != self.currentTitleValue) || (editedContent != self.currentContentValue) else {
            return
        }
        // if there's real changes, update note:
        LogUtils.LogDebug(type: .info, message: "=== Do change model")
        self.note?.updatedAt = Date()
        self.note?.title = editedTitle
        self.note?.content = self.contentTextView.text
        /* update newNote to persistentStore will be executed when the app's going to be terminated or go to the background (using notification) */
    }
    
    // MARK: - Setup When ViewDidLoad:
    
    private func setupView() {
        
        self.tagsLabel.text = note?.alphabetizedTagsAsString ?? "No Tag"
        
        self.updateCategoryLabel()
        
        self.titleTextField.text = self.note?.title
        self.currentTitleValue = (self.note?.title!)!
        
        self.contentTextView.text = self.note?.content
        self.currentContentValue = (self.note?.content)!
    }
    
    private func updateCategoryLabel() {
        self.categoryLabel.text = note?.category?.name ?? "No Category"
    }
    

    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleManagedObjectContextDidChange(notification:)),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: self.note?.managedObjectContext)
    }

    @objc func handleManagedObjectContextDidChange(notification: Notification) {
        LogUtils.LogDebug(type: .info, message: "\(#function) get called")
        // update category for current note:
        guard let userInfo = notification.userInfo else {
            LogUtils.LogDebug(type: .warning, message: "UserInfo is nil")
            return
        }
        // ensure there're some changes happen:
        guard let updatedCategory = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> else {
            LogUtils.LogDebug(type: .info, message: "nothing to update")
            return
        }
        // ensure the current note's category is updated
        var isUpdatedCategory = false
        for ( _ , updatedCategory) in updatedCategory.enumerated() {
            if updatedCategory == self.note?.category {
                isUpdatedCategory = true
            }
        }

        if isUpdatedCategory  {
            LogUtils.LogDebug(type: .info, message: "updateCategoryLabel get called")
            self.updateCategoryLabel()
        }

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
                LogUtils.LogDebug(type: .error, message: "CategoryVC not found")
                return
            }
            desVC.note = self.note
        default:
            break
        }
    }
    
    // MARK: - Helper Functions:
   

}
