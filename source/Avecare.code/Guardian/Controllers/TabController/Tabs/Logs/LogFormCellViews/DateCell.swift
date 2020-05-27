import UIKit
import JTAppleCalendar



class DateCell: JTACDayCell {

    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var hasDataView: UIView!

    var hasData: Bool = false


    func configureCell(cellState: CellState) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        dayOfWeekLabel.text = String(dateFormatter.string(from: cellState.date).first!)
        dateLabel.text = cellState.text

        selectionView.layer.cornerRadius = selectionView.frame.width / 2
        selectionView.clipsToBounds = true
        hasDataView.layer.cornerRadius = hasDataView.frame.width / 2
        hasDataView.clipsToBounds = true

        if cellState.isSelected {
            selectionView.isHidden = false
            dateLabel.textColor = .white
        } else {
            selectionView.isHidden = true
            dateLabel.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }

        let dateBeforWeek = Date.startDateForLogsCalendar.startOfDay
        if cellState.date > Date() ||
            cellState.date < dateBeforWeek ||
            dayOfWeekLabel.text == "S" {
            setDateActive(isActive: false)
        } else {
            setDateActive(isActive: true)
        }

        hasDataView.isHidden = !hasData
    }


    private func setDateActive(isActive: Bool) {
        if isActive {
            dayOfWeekLabel.alpha = 1
            dateLabel.alpha = 1
        } else {
            dayOfWeekLabel.alpha = 0.2
            dateLabel.alpha = 0.2
        }
    }
}
