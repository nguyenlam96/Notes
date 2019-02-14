//
//  CategoryCell.swift
//  Notes
//
//  Created by Nguyen Lam on 2/14/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    // MARK: - Properties:
    static let reuseIdentifier = "CategoryCell"
    
    // MARK: - IBOutlet:
    @IBOutlet weak var nameLabel: UILabel!
    
    
    // MARK: - ViewLifeCycle:
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - Helper Functions:
    func bindData(category: Category) {
        self.nameLabel.text = category.name
    }

}
