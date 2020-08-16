import UIKit
import SnapKit



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


    override func layoutSubviews() {
        super.layoutSubviews()

        selectedSubjectNameLabel.snp.updateConstraints { (make) -> Void in
            make.right.equalToSuperview()
        }
    }


    func refreshView() {
        guard let dataProvider = dataProvider,
              let selectedSubjectId = parentVC?.subjectSelection?.subject?.id else {
            return
        }

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

        subjectsCollectionView.reloadData()
    }


    private func setLabels(forModelAt indexPath: IndexPath) {
        guard let model = dataProvider?.model(at: indexPath) else {
            return
        }
        selectedSubjectNameLabel.text = model.fullName

        if let fontAwesomeFont = R.font.fontAwesome5ProLight(size: 15) {
            let birthDateAttributedString = NSAttributedString(string: Date.fullMonthDayYearFormatter.string(from: model.birthday) + "  \u{f1fd}",
                                                               attributes: [NSAttributedString.Key.font: fontAwesomeFont])
            selectedSubjectDOBLabel.attributedText = birthDateAttributedString

        } else {
            selectedSubjectDOBLabel.text = Date.fullMonthDayYearFormatter.string(from: model.birthday)
        }

        selectedSubjectDOBLabel.textColor = selectedSubjectNameLabel.textColor

        selectedSubjectNameLabel.adjustsFontSizeToFitWidth = true
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
        let height = width * 0.95
        return CGSize(width: width, height: height)
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedModel = dataProvider?.model(at: indexPath) else {
            fatalError()
        }
        setLabels(forModelAt: indexPath)
        parentVC?.subjectSelection?.subject = selectedModel
        parentVC?.updateSupervisors()
    }


    // Scroll snapping
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = subjectsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let bounds = scrollView.bounds
        let xTarget = targetContentOffset.pointee.x

        // This is the max contentOffset.x to allow. With this as contentOffset.x,
        // the right edge of the last column of cells is at the right edge of the collection view's frame.
        let xMax = scrollView.contentSize.width - scrollView.bounds.width

        if abs(velocity.x) <= snapToMostVisibleColumnVelocityThreshold {
            let xCenter = scrollView.bounds.midX
            let poses = layout.layoutAttributesForElements(in: bounds) ?? []
            // Find the column whose center is closest to the collection view's visible rect's center.
            let x = poses.min(by: { abs($0.center.x - xCenter) < abs($1.center.x - xCenter) })?.frame.origin.x ?? 0
            targetContentOffset.pointee.x = x
        } else if velocity.x > 0 {
            let poses = layout.layoutAttributesForElements(in: CGRect(x: xTarget, y: 0, width: bounds.size.width, height: bounds.size.height)) ?? []
            // Find the leftmost column beyond the current position.
            let xCurrent = scrollView.contentOffset.x
            let x = poses.filter({ $0.frame.origin.x > xCurrent}).min(by: { $0.center.x < $1.center.x })?.frame.origin.x ?? xMax
            targetContentOffset.pointee.x = min(x, xMax)
        } else {
            let poses = layout.layoutAttributesForElements(in: CGRect(x: xTarget - bounds.size.width,
                                                                      y: 0,
                                                                      width: bounds.size.width,
                                                                      height: bounds.size.height)) ?? []
            // Find the rightmost column.
            let x = poses.max(by: { $0.center.x < $1.center.x })?.frame.origin.x ?? 0
            targetContentOffset.pointee.x = max(x, 0)
        }
    }


    // Velocity is measured in points per millisecond.
    private var snapToMostVisibleColumnVelocityThreshold: CGFloat {
        return 0.3
    }

}
