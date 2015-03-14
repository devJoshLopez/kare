//
//  StoryListTableViewCell.swift
//  Kare
//
//  Created by Josh Lopez on 3/12/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit

class StoryListTableViewCell: UITableViewCell {
    
    @IBOutlet var cellStoryImage: UIImageView!
    @IBOutlet var cellStoryBeats: UILabel!
    @IBOutlet var cellStoryCommentsCount: UILabel!
    @IBOutlet var cellStoryTitle: UILabel!
    @IBOutlet var cellStoryAuthor: UILabel!
    @IBOutlet var cellStoryDistance: UILabel!
    @IBOutlet var cellStoryDateAdded: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
