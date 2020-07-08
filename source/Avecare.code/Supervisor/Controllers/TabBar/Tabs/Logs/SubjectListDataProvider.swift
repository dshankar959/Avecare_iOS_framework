import UIKit
import CocoaLumberjack



struct Form {
    let viewModels: [AnyCellViewModel]

    init(viewModels: [AnyCellViewModel]) {
        self.viewModels = viewModels
    }
}


protocol SubjectListDataProviderIO: class {
    var delegate: SubjectListDataProviderDelegate? { get set }
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel
    func sortBy(_ sort: SubjectListDataProvider.Sort)
    func setSelected(_ isSelected: Bool, at indexPath: IndexPath)
    func form(at indexPath: IndexPath) -> Form

    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item]
}


protocol SubjectListDataProviderDelegate: UIViewController, CustomResponderProvider {
    func didUpdateModel(at indexPath: IndexPath)
    func didFailure(_ error: Error)
}


class SubjectListDataProvider: SubjectListDataProviderIO, DateSubtitleViewModelDelegate {

    enum Sort: Int {
        case lastName = 0
        case firstName = 1
        case date = 2
    }

    private var selectedId: String?
    var delegate: SubjectListDataProviderDelegate?
    weak var subtitleDateLabel: UILabel?

    var dataSource = [RLMSubject]()
    let imageStorageService = DocumentService()

    var numberOfRows: Int {
        return dataSource.count
    }

    var selectedSubject: RLMSubject? = nil

    func sortBy(_ sort: Sort) {
        switch sort {
        case .firstName: dataSource = RLMSubject.findAll(sortedBy: "firstName")
        case .lastName: dataSource = RLMSubject.findAll(sortedBy: "lastName")
        case .date: dataSource = RLMSubject.findAll(sortedBy: "birthday")
        }
    }

    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel {
        let model = dataSource[indexPath.row]
        var viewModel = SubjectListTableViewCellModel(subject: model, storage: imageStorageService)
        viewModel.isSelected = model.id == selectedId
        return viewModel
    }

    func setSelected(_ isSelected: Bool, at indexPath: IndexPath) {
        let targetId = dataSource[indexPath.row].id
        DDLogVerbose("selected subject: \"\(dataSource[indexPath.row].fullName)\", .id = \(targetId)")
        var indexes = [IndexPath]()

        // update previous selection
        if let last = selectedId, last != targetId,
            let index = dataSource.firstIndex(where: { $0.id == last }) {
            indexes.append(IndexPath(row: index, section: 0))
        }

        // update new selection
        selectedId = targetId
        indexes.append(indexPath)

        indexes.forEach { path in
            delegate?.didUpdateModel(at: path)
        }
    }

    func form(at indexPath: IndexPath) -> Form {
        let subject = dataSource[indexPath.row]
        selectedSubject = subject
        let formLog = subject.todayForm

        let isSubmitted = formLog.publishState != .local
        let title = "\(subject.firstName) \(subject.lastName)'s Log"

        let header: [AnyCellViewModel] = [
            LabelFormViewModel.title(title),
            DateSubtitleViewModel(date: formLog.clientLastUpdated!, isSubmitted: isSubmitted, delegate: self)
                .inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 32, right: 0))
        ]

        let updateClientDate: (Date) -> Void = { [weak self] date in
            let date = Date()
            RLMLogForm.writeTransaction {
                formLog.clientLastUpdated = date
            }
            if let uSelf = self, let label = uSelf.subtitleDateLabel {
                DateSubtitleViewModel(date: date, isSubmitted: isSubmitted, delegate: uSelf).setup(cell: label)
            }
        }

        return Form(viewModels: header + formLog.rows.enumerated().map({ index, row in
            self.viewModel(for: row, editable: !isSubmitted, at: indexPath, for: index, updateCallback: updateClientDate)
        }))
    }


    private func viewModel(for row: RLMLogRow,
                           editable: Bool,
                           at indexPath: IndexPath,
                           for rowIndex: Int,
                           updateCallback: @escaping (Date) -> Void) -> AnyCellViewModel {
        switch row.rowType {
        case .option: return viewModel(for: row.option!, editable: editable, at: indexPath, for: rowIndex, updateCallback: updateCallback)
        case .time: return viewModel(for: row.time!, editable: editable, at: indexPath, for: rowIndex, updateCallback: updateCallback)
        case .switcher: return viewModel(for: row.switcher!, editable: editable, at: indexPath, for: rowIndex, updateCallback: updateCallback)
        case .note: return viewModel(for: row.note!, editable: editable, at: indexPath, for: rowIndex, updateCallback: updateCallback)
        case .photo: return viewModel(for: row.photo!, editable: editable, at: indexPath, for: rowIndex, updateCallback: updateCallback)
        case .injury: return viewModel(for: row.injury!, editable: editable, at: indexPath, for: rowIndex, updateCallback: updateCallback)
        case .tags: return viewModel(for: row.tags!, editable: editable, at: indexPath, for: rowIndex, updateCallback: updateCallback)
        }
    }
}
