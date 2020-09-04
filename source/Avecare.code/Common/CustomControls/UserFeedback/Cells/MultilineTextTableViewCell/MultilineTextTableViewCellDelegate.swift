import Foundation



protocol MultilineTextTableViewCellDelegate: class {

    func multilineTextTableViewCellDidBeginEditing(_ cell: MultilineTextTableViewCell)
    func multilineTextTableViewCellDidEndEditing(_ cell: MultilineTextTableViewCell)
    func multilineTextTableViewCellDidChange(_ cell: MultilineTextTableViewCell)

    func multilineTextTableViewCell(_ cell: MultilineTextTableViewCell,
                                    shouldChangeTextIn range: NSRange,
                                    replacementText text: String) -> Bool

}

extension MultilineTextTableViewCellDelegate {

    func multilineTextTableViewCellDidBeginEditing(_ cell: MultilineTextTableViewCell) {}
    func multilineTextTableViewCellDidEndEditing(_ cell: MultilineTextTableViewCell) {}
    func multilineTextTableViewCellDidChange(_ cell: MultilineTextTableViewCell) {}

    func multilineTextTableViewCell(_ cell: MultilineTextTableViewCell,
                                    shouldChangeTextIn range: NSRange,
                                    replacementText text: String) -> Bool {
        return true
    }

}
