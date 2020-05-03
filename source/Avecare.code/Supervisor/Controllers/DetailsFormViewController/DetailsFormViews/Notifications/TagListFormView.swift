import Foundation
import UIKit
import SnapKit

struct TagListFormViewModel: CellViewModel {
    typealias CellType = TagListFormView

    struct Cell: CellViewModel {
        typealias CellType = TagListFormViewCell

        let name: String

        func setup(cell: CellType) {
            cell.tagButton.setTitle(name, for: .normal)
        }
    }

    var tags: [String]
    var deleteAction: ((Int) -> Void)?

    func setup(cell: CellType) {
        cell.data = tags.map({ Cell(name: $0)})
        cell.onDelete = deleteAction
    }
}

class TagListFormView: ContentSizedTableView {
    fileprivate var data = [TagListFormViewModel.Cell]() {
        didSet {
            reloadData()
        }
    }

    var onDelete: ((Int) -> Void)?

    init() {
        super.init(frame: .zero, style: .plain)
        delegate = self
        dataSource = self
        backgroundColor = .clear
        separatorColor = .clear
        setContentCompressionResistancePriority(.required, for: .vertical)
        register(nibModels: [TagListFormViewModel.Cell.self])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension TagListFormView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withModel: model, for: indexPath)
        cell.delegate = self
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

protocol TagListFormViewCellDelegate: class {
    func didClickTag(_ cell: TagListFormViewCell)
}

class TagListFormViewCell: UITableViewCell {
    @IBOutlet weak var tagButton: UIButton!
    weak var delegate: TagListFormViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        let isLTR = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight

        if isLTR {
            tagButton.semanticContentAttribute = .forceRightToLeft
            tagButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 20)
            tagButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        } else {
            tagButton.semanticContentAttribute = .forceLeftToRight
            tagButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 16)
            tagButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        }

        tagButton.layer.masksToBounds = true
        tagButton.layer.cornerRadius = 4
    }

    @IBAction func didClickTagButton(_ sender: UIButton) {
        delegate?.didClickTag(self)
    }
}

extension TagListFormView: TagListFormViewCellDelegate {
    func didClickTag(_ cell: TagListFormViewCell) {
        guard let indexPath = indexPath(for: cell) else { return }
        onDelete?(indexPath.row)
    }
}
