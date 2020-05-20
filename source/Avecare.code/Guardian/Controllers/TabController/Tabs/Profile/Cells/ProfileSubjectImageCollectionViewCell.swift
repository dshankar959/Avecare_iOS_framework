//
//  ProfileSubjectImageCollectionViewCell.swift
//  educator
//
//  Created by stephen on 2020-05-15.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit

struct ProfileSubjectImageCollectionViewCellModel: CellViewModel {
    typealias CellType = ProfileSubjectImageCollectionViewCell

    let id: String
    let photo: URL?
    let fullName: String
    let birthDay: Date

    func setup(cell: CellType) {
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.width / 2
        cell.avatarImageView.clipsToBounds = true

        cell.subjectSelectView.layer.cornerRadius = cell.subjectSelectView.frame.width / 2
        cell.subjectSelectView.clipsToBounds = true
        if cell.isSelected {
            cell.subjectSelectView.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
        } else {
            cell.subjectSelectView.backgroundColor = .white
        }

        if let photoURL = photo {
            cell.avatarImageView.image = UIImage(contentsOfFile: photoURL.path)
        } else {
            cell.avatarImageView.image = R.image.avatar_default()
        }
    }
}

class ProfileSubjectImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var subjectSelectView: UIView!

    override var isSelected: Bool {
        didSet {
            if isSelected {
                subjectSelectView.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
            } else {
                subjectSelectView.backgroundColor = .white
            }
        }
    }
}
