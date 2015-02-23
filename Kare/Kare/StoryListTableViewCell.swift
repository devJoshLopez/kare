//
//  StoryListTableViewCell.swift
//  Kare
//
//  Created by Josh Lopez on 1/22/15.
//  Copyright (c) 2015 Josh Lopez. All rights reserved.
//

import UIKit

class StoryListTableViewCell: UITableViewCell {

    
    @IBOutlet var storyImagePreview: UIImageView!
    @IBOutlet var storyLovePreview: UILabel!
    @IBOutlet var storyCommentsCountPreview: UILabel!
    @IBOutlet var storyTitlePreview: UILabel!
    @IBOutlet var storyAuthorPreview: UILabel!
    @IBOutlet var storyDistancePreview: UILabel!
    @IBOutlet var storyDatestampPreview: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
