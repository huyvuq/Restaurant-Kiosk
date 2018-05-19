//
//  SideViewTableViewCell.swift
//  Restaurant Kiosk
//
//  Created by Huy Vu on 5/19/18.
//  Copyright © 2018 VietMyApps. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
