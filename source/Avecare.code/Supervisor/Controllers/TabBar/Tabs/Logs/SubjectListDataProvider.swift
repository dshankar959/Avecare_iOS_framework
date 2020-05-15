import Foundation
import UIKit


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


class SubjectListDataProvider: SubjectListDataProviderIO {
    enum Sort: Int {
        case lastName = 0
        case firstName = 1
        case date = 2
    }

    private var selectedId: String?
    var delegate: SubjectListDataProviderDelegate?

    private var dataSource = [RLMSubject]()

    func sortBy(_ sort: Sort) {
        switch sort {
        case .firstName: dataSource = RLMSubject.findAll(sortedBy: "firstName")
        case .lastName: dataSource = RLMSubject.findAll(sortedBy: "lastName")
        case .date: dataSource = RLMSubject.findAll(sortedBy: "birthday")
        }
    }

    var numberOfRows: Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel {
        let model = dataSource[indexPath.row]
        var viewModel = SubjectListTableViewCellModel(subject: model)
        viewModel.isSelected = model.id == selectedId
        return viewModel
    }

    func setSelected(_ isSelected: Bool, at indexPath: IndexPath) {
        let targetId = dataSource[indexPath.row].id
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
        let formLog = subject.todayForm

        let title = "\(subject.firstName) \(subject.lastName)'s Log"
        let header: [AnyCellViewModel] = [
            FormLabelViewModel.title(title),
            FormLabelViewModel.subtitle("Never")
                .inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 32, right: 0))
        ]

        return Form(viewModels: header + formLog.rows.map({ self.viewModel(for: $0, at: indexPath) }))

    }

    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item] {
        let subject = dataSource[indexPath.row]
        let isSubmitted = subject.isFormSubmittedToday

        return [
            .imageButton(options: .init(action: { [weak self] view, options, index in
                let items = RLMLogChooseRow.findAll()

                let picker = SingleValuePickerView(values: items)
                picker.backgroundColor = .white

                guard let toolbar = self?.defaultToolbarView(onDone: {
                    guard let subject = self?.dataSource[indexPath.row],
                        let row = picker.selectedValue?.row else {
                            return
                    }

                    self?.delegate?.customResponder?.resignFirstResponder()

                    let logForm = subject.todayForm
                    RLMLogForm.writeTransaction {
                        logForm.rows.append(row.detached())
                    }

                    self?.delegate?.didUpdateModel(at: indexPath)

                }, onCancel: {
                    self?.delegate?.customResponder?.resignFirstResponder()
                }) else {
                    return
                }

                self?.delegate?.customResponder?.becomeFirstResponder(inputView: picker, accessoryView: toolbar)

                }, isEnabled: !isSubmitted, image: R.image.plusIcon())),
            .offset(value: 10),
            .button(options: .init(action: { [weak self] view, options, index in

                }, isEnabled: !isSubmitted, text: "Publish", textColor: R.color.mainInversion(), cornerRadius: 4))

        ]
    }

    func viewModel(for row: RLMLogRow, at indexPath: IndexPath) -> AnyCellViewModel {
        // swiftlint:disable:force_cast
        switch row.rowType {
        case .option: return viewModel(for: row.option!, at: indexPath)
        case .time: return viewModel(for: row.time!, at: indexPath)
        case .switcher: return viewModel(for: row.switcher!, at: indexPath)
        case .note: return viewModel(for: row.note!, at: indexPath)
        case .photo: return viewModel(for: row.photo!, at: indexPath)
        case .injury: return viewModel(for: row.injury!, at: indexPath)
            // swiftlint:enable:force_cast
        }
    }
}
