//
//  NoteCell.swift
//  Notes
//
//  Created by Nguyen Lam on 2/13/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    
    // MARK: - Properties:
    static let reuseIdentifier = "NoteTableViewCell"
    
    // MARK: - IBOutlet:
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    // MARK: - ViewLifeCycle:
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - Helper :
    func bindData(note: Note) {
        
        self.titleLabel.text = note.title
        self.contentLabel.text = note.content
        self.updatedAtLabel.text = customDateFormatter().string(from: note.updatedAtAsDate)
    }

}
