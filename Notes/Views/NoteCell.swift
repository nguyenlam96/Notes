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
    static let reuseIdentifier = "NoteCell"
    
    // MARK: - IBOutlet:
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dashLineColor: UIView!
    @IBOutlet weak var tagsLabel: UILabel!
    
    
    // MARK: - ViewLifeCycle:
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - IBAction:
    @IBAction func tagsButtonPressed(_ sender: UIButton) {
        
    }
    
    // MARK: - Helper :
    func bindData(note: Note) {
        
        self.dashLineColor.backgroundColor = note.category?.color ?? .white
        self.titleLabel.text = note.title
        self.tagsLabel.text = note.alphabetizedTagsAsString ?? "No tags"
        self.contentLabel.text = note.content
        self.updatedAtLabel.text = customDateFormatter().string(from: note.updatedAtAsDate)

    }

}
