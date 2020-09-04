import Foundation
import UIKit



enum UserFeedbackSection {

    case feedback
    case none


    var allRows: [UserFeedbackRow] {
        switch self {
        case .feedback:
            return [ UserFeedbackRow.comments,
                     UserFeedbackRow.logfiles,
                     UserFeedbackRow.send ]
        default:
            return []
        }
    }


    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .feedback
        default: self = .none
        }
    }


}
