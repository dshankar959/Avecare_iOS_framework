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

    weak var dataProvider: SubjectListDataProvider?

    func setup(cell: CellType) {
        cell.dataProvider = dataProvider
    }

}

class ProfileSubjectTableViewCell: UITableViewCell {

    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    @IBOutlet weak var selectedSubjectNameLabel: UILabel!
    @IBOutlet weak var selectedSubjectDOBLabel: UILabel!

    weak var dataProvider: SubjectListDataProvider?

    override func awakeFromNib() {
        super.awakeFromNib()

        subjectsCollectionView.register(nibModels: [
            ProfileSubjectImageCollectionViewCellModel.self
        ])
    }

    func refreshView() {
        if let dataProvider = dataProvider {
            if let selectedSubjectId = selectedSubjectId {
                for i in 0..<dataProvider.numberOfRows {
                    let indexPath = IndexPath(row: i, section: 0)
                    let model = dataProvider.imageCollectionViewmodel(for: indexPath)
                    if model.id == selectedSubjectId {
                        setLabels(withSelectedModel: model)
                        subjectsCollectionView.scrollToItem(at: indexPath, at: .right, animated: false)
                        break
                    }
                }
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                let model = dataProvider.imageCollectionViewmodel(for: indexPath)
                setLabels(withSelectedModel: model)
                subjectsCollectionView.scrollToItem(at: indexPath, at: .right, animated: false)
            }
        }

        subjectsCollectionView.reloadData()
    }

    private func setLabels(withSelectedModel model: ProfileSubjectImageCollectionViewCellModel) {
        selectedSubjectNameLabel.text = model.fullName
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        selectedSubjectDOBLabel.text = formatter.string(from: model.birthDay)
    }
}

extension ProfileSubjectTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider?.numberOfRows ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = dataProvider?.imageCollectionViewmodel(for: indexPath) else {
            fatalError()
        }
        let cell = collectionView.dequeueReusableCell(withModel: model, for: indexPath)
        if let selectedSubjectId = selectedSubjectId {
            if model.id == selectedSubjectId {
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
        } else {
            if indexPath.row == 0 {
                cell.isSelected = true
                setLabels(withSelectedModel: model)
            }
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
        guard let selectedModel = dataProvider?.imageCollectionViewmodel(for: indexPath) else {
            fatalError()
        }
        setLabels(withSelectedModel: selectedModel)
        selectedSubjectId = selectedModel.id
    }
}
