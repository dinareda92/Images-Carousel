//
//  ImageTableViewCell.swift
//  Images Carousel
//
//  Created by Dina Reda on 4/22/21.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imageItem: UIImageView!
    
    @IBOutlet weak var labelItme: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
