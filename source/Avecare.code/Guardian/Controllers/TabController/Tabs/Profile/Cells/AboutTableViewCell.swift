//
//  AboutTableViewCell.swift
//  educator
//
//  Created by stephen on 2020-05-19.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit

struct AboutTableViewCellModel: CellViewModel {
    typealias CellType = AboutTableViewCell

    var menuTitle: String

    func setup(cell: AboutTableViewCell) {
        cell.menuTitleLabel.text = menuTitle
    }

}

class AboutTableViewCell: UITableViewCell {

    @IBOutlet weak var menuTitleLabel: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
