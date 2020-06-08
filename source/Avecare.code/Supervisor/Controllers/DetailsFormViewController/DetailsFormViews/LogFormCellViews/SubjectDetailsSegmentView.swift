import UIKit



class SubjectDetailsSegmentView: BaseXibView {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedOptionButton: UIButton!

    @IBOutlet weak var segmentDescriptionLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    var onClick: ((SubjectDetailsSegmentView) -> Void)?
    var onSegmentChange: ((SubjectDetailsSegmentView, Int) -> Void)?

    override func setup() {
        super.setup()

        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12
    }

    @IBAction func didChangeSegmentControlValue(_ sender: UISegmentedControl) {
        onSegmentChange?(self, sender.selectedSegmentIndex)
    }

    @IBAction func didClickOptionButton(_ sender: UIButton) {
        onClick?(self)
    }

}


struct SubjectDetailsSegmentViewModel: CellViewModel {
    typealias CellType = SubjectDetailsSegmentView

    struct Action {
        var onClick: ((CellType) -> Void)?
        var onSegmentChange: ((CellType, Int) -> Void)?
    }

    let icon: UIImage?
    let iconColor: UIColor?
    let title: String
    var selectedOption: String

    let segmentDescription: String
    let segmentValues: [String]
    var selectedSegmentIndex: Int = 0

    var action: Action? = nil

    let isEditable: Bool

    func setup(cell: CellType) {
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.tintColor = iconColor
        cell.iconImageView.image = icon
        cell.titleLabel.text = title

        cell.selectedOptionButton.setTitle(selectedOption, for: .normal)

        cell.segmentDescriptionLabel.text = segmentDescription
        cell.segmentControl.removeAllSegments()
        for i in 0..<segmentValues.count {
            cell.segmentControl.insertSegment(withTitle: segmentValues[i], at: i, animated: false)
        }
        cell.segmentControl.selectedSegmentIndex = selectedSegmentIndex

        if isEditable {
            cell.onClick = action?.onClick
            cell.onSegmentChange = action?.onSegmentChange
            cell.segmentControl.isUserInteractionEnabled = true
        } else {
            cell.segmentControl.isUserInteractionEnabled = false
        }
    }

}
