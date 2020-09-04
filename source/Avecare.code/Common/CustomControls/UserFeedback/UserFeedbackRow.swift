import Foundation
import UIKit



enum UserFeedbackRow {

    case comments
    case logfiles
    case send
    case none


    var reuseIdentifier: String {
        switch self {
        case .comments:
            return MultilineTextTableViewCell.reuseIdentifier
        case .logfiles:
            return ToggleTableViewCell.reuseIdentifier
        case .send:
            return ButtonTableViewCell.reuseIdentifier
        case .none:
            return "userFeedbackRow"
        }
    }

    var rowHeight: CGFloat {
        switch self {
        case .comments:
            return 180
        case .logfiles, .send, .none:
            return 60
        }
    }

}
