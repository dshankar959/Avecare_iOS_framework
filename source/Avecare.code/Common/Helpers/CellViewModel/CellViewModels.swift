import Foundation
import UIKit



public protocol AnyCellViewModel {
    static var cellType: UIView.Type { get }
    func setup(cell: UIView)
    func buildView() -> UIView
}

public protocol CellViewModel: AnyCellViewModel {
    associatedtype CellType: UIView
    func setup(cell: CellType)
}

public extension CellViewModel {
    static var cellType: UIView.Type {
        return CellType.self
    }

    func setup(cell: UIView) {
        guard let cell = cell as? CellType else { fatalError("CellViewModel: Wrong type") }
        self.setup(cell: cell)
    }

    func buildView() -> UIView {
        let view = CellType.init()
        self.setup(cell: view)
        return view
    }
}

// MARK: - Table View

public extension UITableView {

    func dequeueReusable<T: UITableViewCell>(cell: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: cell), for: indexPath) as? T else {
            fatalError("CellViewModel: Wrong type")
        }
        return cell
    }

    func dequeueReusableCell<T: CellViewModel>(withModel viewModel: T, for indexPath: IndexPath) -> T.CellType {
        let identifier = String(describing: type(of: viewModel).cellType)
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T.CellType else {
            fatalError("CellViewModel: Wrong type")
        }
        viewModel.setup(cell: cell)
        return cell
    }

    /// Use `AnyCellViewModel`, because CellViewModel type can be used only as generic constraint (because it has associatedtype)
    func dequeueReusableCell(withAnyModel viewModel: AnyCellViewModel, for indexPath: IndexPath, owner: Any? = nil) -> UITableViewCell {
        let identifier = String(describing: type(of: viewModel).cellType)

        let cell: UITableViewCell
        if let owner = owner {
            if let dequeue = dequeueReusableCell(withIdentifier: identifier) {
                cell = dequeue
            } else if let dequeue = Bundle.main.loadNibNamed(identifier, owner: owner, options: nil)?.first as? UITableViewCell {
                cell = dequeue
            } else {
                fatalError("Can not find \(identifier).xib")
            }
        } else {
            cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }

        viewModel.setup(cell: cell)
        return cell
    }

    func register(nibModels: [AnyCellViewModel.Type]) {
        for model in nibModels {
            let identifier = String(describing: model.cellType)
            let nib = UINib(nibName: identifier, bundle: nil)
            register(nib, forCellReuseIdentifier: identifier)
        }
    }

    func register(viewModels: [AnyCellViewModel.Type]) {
        for model in viewModels {
            let identifier = String(describing: model.cellType)
            register(model.cellType, forCellReuseIdentifier: identifier)
        }
    }

    func register(cells: [UITableViewCell.Type]) {
        for cell in cells {
            register(cell, forCellReuseIdentifier: String(describing: cell))
        }
    }
}

// MARK: - Collection View

public extension UICollectionView {

    func dequeueReusableCell<T: CellViewModel>(withModel viewModel: T, for indexPath: IndexPath) -> T.CellType {
        let identifier = String(describing: type(of: viewModel).cellType)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T.CellType else {
            fatalError("CellViewModel: Wrong type")
        }
        viewModel.setup(cell: cell)
        return cell
    }

    func dequeueReusableCell(withAnyModel viewModel: AnyCellViewModel, for indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: type(of: viewModel).cellType)
        let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        viewModel.setup(cell: cell)
        return cell
    }

    func register(nibModels: [AnyCellViewModel.Type]) {
        nibModels.map({ String(describing: $0.cellType) })
                .forEach({ register(UINib(nibName: $0, bundle: nil), forCellWithReuseIdentifier: $0) })
    }

    func register(viewModels: [AnyCellViewModel.Type]) {
        for model in viewModels {
            let identifier = String(describing: model.cellType)
            register(model.cellType, forCellWithReuseIdentifier: identifier)
        }
    }
}
