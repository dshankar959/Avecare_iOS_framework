import Foundation
import RealmSwift


protocol EducatorDetailsDataProvider: class {
    var numberOfSections: Int { get }
    func numberOfRows(section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    func createDataProvider(with educatorId: String)
}

class DefaultEducatorDetailsDataProvider: EducatorDetailsDataProvider {
    private struct Section {
        let records: [AnyCellViewModel]
    }

    private var dataSource = [Section]()

    func createDataProvider(with educatorId: String) {
        let selectedEducator = RLMSupervisor.find(withID: educatorId)
        dataSource.append(Section(records: [
            EducatorBioTableViewCellModel(title: selectedEducator?.title ?? "Ms.",
                                          lastname: selectedEducator?.lastName ?? "",
                                          bio: selectedEducator?.bio ?? "")
        ]))
        if let educationalBackground = selectedEducator?.educationalBackground {
            let sortedEducations = Array(educationalBackground).sorted { $0.yearCompleted > $1.yearCompleted }
            var logsNotes = [LogsNoteTableViewCellModel]()
            sortedEducations.forEach { education in
                let logsNote = LogsNoteTableViewCellModel(icon: R.image.certificationIcon(),
                                                          iconColor: R.color.blueIcon(),
                                                          title: education.title,
                                                          text: education.institute + " - \(education.yearCompleted)")
                logsNotes.append(logsNote)
            }
            dataSource.append(Section(records: logsNotes))
        }
    }

    var numberOfSections: Int {
        return dataSource.count
    }

    func numberOfRows(section: Int) -> Int {
        return dataSource[section].records.count
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        return dataSource[indexPath.section].records[indexPath.row]
    }
}
