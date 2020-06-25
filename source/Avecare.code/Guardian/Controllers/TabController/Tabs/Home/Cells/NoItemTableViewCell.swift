//
//  NoItemTableViewCell.swift
//  educator
//
//  Created by stephen on 2020-06-25.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit

class NoItemTableViewCell: UITableViewCell {
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemContentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        noItemTitleLabel.text = NSLocalizedString("home_no_item_title", comment: "")
        noItemContentLabel.text = NSLocalizedString("home_no_item_content", comment: "")
    }
}
