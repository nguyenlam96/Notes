//
//  ColorPickerVC.swift
//  Notes
//
//  Created by Nguyen Lam on 2/14/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

protocol ColorPickerVCDelegate: class {
    
    func controller(_ controller: ColorPickerVC, didPick color: UIColor)
    
}

class ColorPickerVC: UIViewController {
    
    // MARK: - Properties:
    var color: UIColor?
    weak var delegate: ColorPickerVCDelegate?
    var pickedColor: UIColor = .white
    
    // MARK: - IBOutlet:
    @IBOutlet weak var redSlide: UISlider!
    @IBOutlet weak var greenSlide: UISlider!
    @IBOutlet weak var blueSlide: UISlider!
    @IBOutlet weak var previewColorView: UIView!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Color Picker"
        self.setupPreviewColorView()
    }
    
    deinit {
        print("=== ColorPickerVC is deinit")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.delegate?.controller(self, didPick: self.pickedColor)
    }
    
    // MARK: - Setup When ViewDidLoad:
    func setupPreviewColorView() {
        let color = UIColor(r: redSlide.value, g: greenSlide.value, b: blueSlide.value)!
        self.previewColorView.backgroundColor = color
    }
    
    @IBAction func redSlideValueChanged(_ sender: UISlider) {
        let color = UIColor(r: sender.value, g: greenSlide.value, b: blueSlide.value)!
        self.previewColorView.backgroundColor = color
        self.pickedColor = color
    }
    
    @IBAction func greenSlideValueChanged(_ sender: UISlider) {
        let color = UIColor(r: redSlide.value, g: sender.value, b: blueSlide.value)!
        self.previewColorView.backgroundColor = color
        self.pickedColor = color
    }
    
    @IBAction func blueSlideValueChanged(_ sender: UISlider) {

        let color = UIColor(r: redSlide.value, g: greenSlide.value, b: sender.value)!
        self.previewColorView.backgroundColor = color
        self.pickedColor = color
    }
    
    
}
