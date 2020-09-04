import Foundation
import UIKit

struct LabelFormViewModel: CellViewModel {
    typealias CellType = UILabel

    let font: UIFont
    let color: UIColor?
    let text: String

    static func title(_ text: String) -> Self {
        return self.init(font: .systemFont(ofSize: 24, weight: .bold), color: R.color.darkText(), text: text)
    }

    static func subtitle(_ text: String) -> Self {
        return self.init(font: .systemFont(ofSize: 14), color: R.color.lightText2(), text: text)
    }

    func setup(cell: CellType) {
        cell.text = text
        cell.font = font
        cell.textColor = color
        cell.numberOfLines = 0
        cell.setContentCompressionResistancePriority(.required, for: .vertical)
    }

}
