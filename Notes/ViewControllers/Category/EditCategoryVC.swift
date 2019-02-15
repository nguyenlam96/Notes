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
    private var currentColor: UIColor?
    
    // MARK: - Properties:
    @IBOutlet weak var categoryNameTextField: UITextField!
     @IBOutlet weak var colorView: UIButton!
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
        let editedName = self.categoryNameTextField.text
        let editedColor = self.colorView.backgroundColor
//        guard let editedName = self.categoryNameTextField.text, (editedName != self.currentCategoryName) else {
//            LogUtils.LogDebug(type: .info, message: "There's nothing changes")
//            return
//        }
        guard (editedName != self.currentCategoryName) || (editedColor != self.currentColor) else {
            LogUtils.LogDebug(type: .info, message: "There's nothing changes")
            return
        }
        // do change:
        LogUtils.LogDebug(type: .info, message: "Update Category")
        category.name = editedName
//        category.color = editedColor // color is already updated at  controller(_ controller: ColorPickerVC, didPick color: UIColor)
        /* save updatedCategory to persistentStore will be executed when the app's going to be terminated or go to the background (using notification) */
    }
    
    deinit {
        print("EditCategoryVC is deinit")
    }

    // MARK: - Setup When ViewDidLoad:
    private func setupView() {
        self.categoryNameTextField.text = self.category?.name
        self.currentCategoryName = (self.category?.name)!
        self.colorView.backgroundColor = self.category?.color
        self.currentColor = self.category?.color
    }
    
    // MARK: Navigation:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            LogUtils.LogDebug(type: .error, message: "Can't find segue identifier")
            return
        }
        
        switch identifier {
        case "gotoColorPickerVC":
            guard let desVC = segue.destination as? ColorPickerVC else {
                LogUtils.LogDebug(type: .error, message: "Can't get desVC")
                return
            }
            desVC.delegate = self
            desVC.color = self.category?.color ?? .white
        default:
            break
        }
    }

    // MARK: - Helper Functions:
    private func updateColorView(with color: UIColor){
        
        self.colorView.backgroundColor = color
    }
    
}

extension EditCategoryVC: ColorPickerVCDelegate {
    
    func controller(_ controller: ColorPickerVC, didPick color: UIColor) {
        LogUtils.LogDebug(type: .info, message: "\(#function) get called")
        self.category?.color = color
        self.updateColorView(with: color)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTI_DASHLINE_COLOR_CHANGED), object: self, userInfo: ["category" : self.category ?? nil])
    }
}
