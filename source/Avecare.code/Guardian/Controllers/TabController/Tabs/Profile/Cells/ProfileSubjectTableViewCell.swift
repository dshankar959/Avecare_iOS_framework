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
    weak var parentVC: ProfileViewController?

    override func awakeFromNib() {
        super.awakeFromNib()

        subjectsCollectionView.register(nibModels: [
            ProfileSubjectImageCollectionViewCellModel.self
        ])
    }

    func refreshView() {
        guard let dataProvider = dataProvider,
              let selectedSubjectId = parentVC?.subjectSelection?.subject?.id else {
            return
        }
        subjectsCollectionView.reloadData()

        let visibleIndexPaths = subjectsCollectionView.indexPathsForVisibleItems
        for i in 0..<dataProvider.numberOfRows {
            let indexPath = IndexPath(row: i, section: 0)
            let model = dataProvider.model(at: indexPath)
            if model.id == selectedSubjectId {
                setLabels(forModelAt: indexPath)
                if !visibleIndexPaths.contains(indexPath) {
                    subjectsCollectionView.scrollToItem(at: indexPath, at: .right, animated: false)
                }
                break
            }
        }

    }

    private func setLabels(forModelAt indexPath: IndexPath) {
        guard let model = dataProvider?.model(at: indexPath) else {
            return
        }
        selectedSubjectNameLabel.text = model.fullName
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        selectedSubjectDOBLabel.text = formatter.string(from: model.birthday)
    }
}

extension ProfileSubjectTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider?.numberOfRows ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = dataProvider?.profileCellViewModel(for: indexPath) else {
            fatalError()
        }
        let cell = collectionView.dequeueReusableCell(withModel: model, for: indexPath)
        if let selectedSubjectId = parentVC?.subjectSelection?.subject?.id {
            if model.id == selectedSubjectId {
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
        } else {
            if indexPath.row == 0 {
                cell.isSelected = true
                setLabels(forModelAt: indexPath)
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
        guard let selectedModel = dataProvider?.model(at: indexPath) else {
            fatalError()
        }
        setLabels(forModelAt: indexPath)
        parentVC?.subjectSelection?.subject = selectedModel
        parentVC?.updateEducators()
    }
}
