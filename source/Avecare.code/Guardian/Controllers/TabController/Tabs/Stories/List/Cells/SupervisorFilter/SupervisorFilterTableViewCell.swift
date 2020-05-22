import Foundation
import UIKit

struct SupervisorFilterTableViewCellModel: CellViewModel {
    typealias CellType = SupervisorFilterTableViewCell

    weak var dataProvider: EducatorsDataProvider?

    func setup(cell: CellType) {
        cell.dataProvider = dataProvider
    }
}

class SupervisorFilterTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    weak var dataProvider: EducatorsDataProvider?
    weak var parentVC: UIViewController?

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.register(nibModels: [
            SupervisorCollectionViewCellModel.self
        ])
    }

    func refreshView() {
        collectionView.reloadData()
    }
}

extension SupervisorFilterTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider?.numberOfRows ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = dataProvider?.model(for: indexPath) else {
            fatalError()
        }
        return collectionView.dequeueReusableCell(withModel: model, for: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width / 4
        let height = width * 1.1 // + 10%
        return CGSize(width: width, height: height)
    }

    // Scroll snapping
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let parentVC = parentVC as? ViewControllerWithSupervisorFilterViewCell,
            let selectedModel = dataProvider?.model(for: indexPath) {
            parentVC.educatorDidSelect(selectedEducatorId: selectedModel.id)
        }
    }
}

protocol ViewControllerWithSupervisorFilterViewCell: class {
    func educatorDidSelect(selectedEducatorId: String)
}
