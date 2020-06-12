import UIKit



protocol DateSubtitleViewModelDelegate: class {
    var subtitleDateLabel: UILabel? { get set }
}


struct DateSubtitleViewModel: CellViewModel {
    typealias CellType = UILabel

    let date: Date
    let isSubmitted: Bool
    let delegate: DateSubtitleViewModelDelegate?

    func setup(cell: CellType) {
        let formatter = Date.fullMonthTimeFormatter
        let prefix = isSubmitted ? "Published" : "Last saved"
        let time = formatter.string(from: date)

        cell.text = "\(prefix) - \(time)"
        cell.font = .systemFont(ofSize: 14)
        cell.textColor = R.color.lightText2()
        cell.numberOfLines = 0
        cell.setContentCompressionResistancePriority(.required, for: .vertical)

        delegate?.subtitleDateLabel = cell
    }
}
