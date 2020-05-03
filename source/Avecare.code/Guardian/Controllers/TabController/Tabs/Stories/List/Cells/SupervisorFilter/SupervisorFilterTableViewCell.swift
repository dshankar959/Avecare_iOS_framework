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

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.register(nibModels: [
            SupervisorCollectionViewCellModel.self
        ])
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

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width / 4
        let height = width * 1.1 // + 10%
        return CGSize(width: width, height: height)
    }
}
