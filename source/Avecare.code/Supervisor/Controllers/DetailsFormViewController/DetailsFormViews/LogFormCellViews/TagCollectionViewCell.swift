import UIKit

protocol TagCollectionViewCellDelegate: class {
    func removeButtonDidClick(_ cell: TagCollectionViewCell)
}

class TagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!

    weak var delegate: TagCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        tagView.clipsToBounds = true
        tagView.layer.cornerRadius = 4
    }

    @IBAction func removeButtonTouched(_ sender: UIButton) {
        delegate?.removeButtonDidClick(self)
    }
}

extension SubjectDetailsTagsView: TagCollectionViewCellDelegate {
    func removeButtonDidClick(_ cell: TagCollectionViewCell) {
        guard let indexPath = tagsCollectionView.indexPath(for: cell) else { return }
        onDelete?(indexPath.row)
    }
}
