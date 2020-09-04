import CocoaLumberjack
import Foundation
import ZIPFoundation



class UserFeedbackViewModel {

    var userComments: String = ""
    var includeLogfiles: Bool = true


    var allSections: [UserFeedbackSection] {
        return [ .feedback ]
    }


    var sectionCount: Int {
        return self.allSections.count
    }


    func count(for section: Int) -> Int {
        return UserFeedbackSection(rawValue: section).allRows.count
    }


    func row(for indexPath: IndexPath) -> UserFeedbackRow {
        let section = allSections[indexPath.section]
        let row = section.allRows[indexPath.row]

        return row
    }


    // MARK: -

    init() {
        DDLogInfo("")
    }

}
