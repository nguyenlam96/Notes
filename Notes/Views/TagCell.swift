//
//  TagCell.swift
//  Notes
//
//  Created by Nguyen Lam on 2/15/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {
    
    // MARK: - Properties:
    static let reuseIdentifier = "TagCell"
    
    // MARK: - IBOutlet:
    @IBOutlet weak var tagNameLabel: UILabel!
    
    
    // MARK: - ViewLifeCycle:
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - Helper Functions:
    func bindData(with tag: Tag) {
        self.tagNameLabel.text = tag.name
        
        
        
    }

}
