import Foundation
import UIKit

struct SubjectDetailsTagsViewModel: CellViewModel {
    typealias CellType = SubjectDetailsTagsView

    let icon: UIImage?
    let iconColor: UIColor?
    let title: String
    var selectOptionTitle: String
    var action: ((CellType) -> Void)? = nil
    var deleteAction: ((Int) -> Void)?
    var onRemoveCell: (() -> Void)? = nil
    let isEditable: Bool
    var selectedOptions = [RLMOptionValue]()

    func setup(cell: CellType) {
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.tintColor = iconColor
        cell.iconImageView.image = icon
        cell.titleLabel.text = title
        cell.selectOptionButton.setTitle(selectOptionTitle, for: .normal)
        cell.selectedOptions = selectedOptions
        cell.isEditable = isEditable

        if isEditable {
            cell.onClick = action
            cell.onDelete = deleteAction
            cell.onRemoveCell = onRemoveCell
        }
    }
}


class SubjectDetailsTagsView: LogFormCellView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectOptionButton: UIButton!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionViewHeight: NSLayoutConstraint!

    let tagCollectionViewCellIdentifier = "TagCollectionViewCell"

    var selectedOptions = [RLMOptionValue]()
    var onClick: ((SubjectDetailsTagsView) -> Void)?
    var onDelete: ((Int) -> Void)?

    var isEditable = false

    override func setup() {
        super.setup()

        tagsCollectionView.register(UINib.init(nibName: "TagCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: tagCollectionViewCellIdentifier)

        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        tagsCollectionView.layoutIfNeeded()

        let contentHeight = tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
        if contentHeight > 0 {
            tagsCollectionViewHeight.constant = contentHeight + 16
        } else {
            tagsCollectionViewHeight.constant = contentHeight
        }
    }

    @IBAction func selectOptionButtonTouched(_ sender: UIButton) {
        onClick?(self)
    }
}

extension SubjectDetailsTagsView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCollectionViewCellIdentifier, for: indexPath) as! TagCollectionViewCell
        cell.titleLabel.text = selectedOptions[indexPath.row].text
        cell.isEditable = self.isEditable
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 200, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 20.0)
    }
}
