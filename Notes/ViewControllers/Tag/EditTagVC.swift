//
//  EditTagVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/15/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class EditTagVC: UIViewController {

    // MARK: - Properties:
    var tag: Tag?
    private var currentTagName = ""
    
    // MARK: - IBOutlet:
    @IBOutlet weak var tagNameTextField: UITextField!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Tag"
        self.setupView()
    }
    deinit {
        print("=== EditTagVC is deinit")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        guard let _ = self.tag?.managedObjectContext else {
            LogUtils.LogDebug(type: .error, message: "managedObjectContext is nil")
            return
        }
        guard let _ = self.tag else {
            LogUtils.LogDebug(type: .error, message: "tag is nil")
            return
        }
        let editedTagName = self.tagNameTextField.text
        guard (editedTagName != self.currentTagName) else {
            LogUtils.LogDebug(type: .info, message: "tagName is not change!")
            return
        }
        // do change model:
        LogUtils.LogDebug(type: .info, message: "== Do change model")
        self.tag?.name = editedTagName
    }

    // MARK: - Setup When ViewDidLoad:
    func setupView() {
        
        self.tagNameTextField.text = self.tag?.name
        self.currentTagName = (self.tag?.name)!
    }
    
}
