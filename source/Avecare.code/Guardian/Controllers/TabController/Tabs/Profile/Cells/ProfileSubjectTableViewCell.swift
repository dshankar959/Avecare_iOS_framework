//
//  ProfileSubjectTableViewCell.swift
//  educator
//
//  Created by stephen on 2020-05-15.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit

struct ProfileSubjectTableViewCellModel: CellViewModel {
    typealias CellType = ProfileSubjectTableViewCell

    weak var dataProvider: SubjectsDataProvider?

    func setup(cell: CellType) {
        cell.dataProvider = dataProvider
    }

}

class ProfileSubjectTableViewCell: UITableViewCell {

    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    @IBOutlet weak var selectedSubjectNameLabel: UILabel!
    @IBOutlet weak var selectedSubjectDOBLabel: UILabel!

    weak var dataProvider: SubjectsDataProvider?

    override func awakeFromNib() {
        super.awakeFromNib()

        subjectsCollectionView.register(nibModels: [
            ProfileSubjectImageCollectionViewCellModel.self
        ])
    }

    private func setLabels(withSelectedModel model: ProfileSubjectImageCollectionViewCellModel) {
        selectedSubjectNameLabel.text = model.fullName
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        selectedSubjectDOBLabel.text = formatter.string(from: model.dateOfBirth ?? Date())
    }
}

extension ProfileSubjectTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider?.numberOfRows ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = dataProvider?.model(for: indexPath) else {
            fatalError()
        }
        let cell = collectionView.dequeueReusableCell(withModel: model, for: indexPath)
        if indexPath.row == 0 {
            cell.isSelected = true
            setLabels(withSelectedModel: model)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width / 3
        let height = width
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedModel = dataProvider?.model(for: indexPath) else {
            fatalError()
        }
        setLabels(withSelectedModel: selectedModel)
    }
}
