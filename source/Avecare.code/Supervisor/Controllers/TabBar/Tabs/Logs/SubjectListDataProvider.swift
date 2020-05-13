import Foundation
import UIKit


// FIXME: testing data, remove it later
extension UIImage {
    static var randomSubjectPhoto: UIImage {
        let images = [R.image.subject1(),
                      R.image.subject2(),
                      R.image.subject3(),
                      R.image.subject4(),
                      R.image.subject5(),
                      R.image.subject6(),
                      R.image.subject7(),
                      R.image.subject8()]

        return images.randomElement()!!
    }
}


struct Form {
    let viewModels: [AnyCellViewModel]

    init(viewModels: [AnyCellViewModel]) {
        self.viewModels = viewModels
    }
}

protocol SubjectListDataProvider: class {

    var delegate: SubjectListDataProviderDelegate? { get set }
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel
    func sortBy(_ sort: SubjectListTableViewCellModel.Sort)
    func setSelected(_ isSelected: Bool, at indexPath: IndexPath)
    func form(at indexPath: IndexPath) -> Form

    func fetch()

    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item]
}


protocol SubjectListDataProviderDelegate: UIViewController, CustomResponderProvider {
    func didUpdateModel(at indexPath: IndexPath)
    func didFetchDataSource()
    func didFailure(_ error: Error)
}


class DefaultSubjectListDataProvider: SubjectListDataProvider {

    private var selectedId: String?
    var delegate: SubjectListDataProviderDelegate?

//    private var dataSource: Results<RLMSubject>?
    private var dataSource: [RLMSubject]?

    func sortBy(_ sort: SubjectListTableViewCellModel.Sort) {
        switch sort {
        case .firstName: dataSource = RLMSubject().findAll(sortedBy: "firstName")
        case .lastName: dataSource = RLMSubject().findAll(sortedBy: "lastName")
        case .date: dataSource = RLMSubject().findAll(sortedBy: "birthday")

//        case .firstName: dataSource = dataSource?.sorted(byKeyPath: "firstName")
//        case .lastName: dataSource = dataSource?.sorted(byKeyPath: "lastName")
//        case .date: dataSource = dataSource?.sorted(byKeyPath: "birthday")
        }
    }

    var numberOfRows: Int {
        return dataSource?.count ?? 0
    }

    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel {
        guard let model = dataSource?[indexPath.row] else {
            fatalError()
        }
        var viewModel = SubjectListTableViewCellModel(image: UIImage.randomSubjectPhoto,
                                                      firstName: model.firstName,
                                                      lastName: model.lastName,
                                                      date: model.birthday, isChecked: false)
        viewModel.isSelected = model.id == selectedId
        return viewModel
    }

    func setSelected(_ isSelected: Bool, at indexPath: IndexPath) {
        guard let dataSource = dataSource else {
            return
        }

        let targetId = dataSource[indexPath.row].id
        var indexes = [IndexPath]()
        if isSelected {
            if let last = selectedId {
                if last != targetId {
                    // deselect
                    if let index = dataSource.firstIndex(where: { $0.id == last }) {
                        indexes.append(IndexPath(row: index, section: 0))
                    }

                } else {
                    // already selected
                    return
                }
            }
            selectedId = targetId
            indexes.append(indexPath)
        } else {
            guard let last = selectedId, last == targetId else {
                return
            }
            selectedId = nil
            indexes.append(indexPath)
        }
        indexes.forEach { path in
            delegate?.didUpdateModel(at: path)
        }
    }

    func form(at indexPath: IndexPath) -> Form {
        guard let subject = dataSource?[indexPath.row] else {
            return Form(viewModels: [])
        }
        guard let formLog = RLMLogForm().find(withSubjectID: subject.id) else {
            return Form(viewModels: [])
        }

        let title = "\(subject.firstName) \(subject.lastName)'s Log"
        let header: [AnyCellViewModel] = [
            FormLabelViewModel.title(title),
            FormLabelViewModel.subtitle("Never")
                .inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 32, right: 0))
        ]

        return Form(viewModels: header + formLog.rows.map({ self.viewModel(for: $0, at: indexPath) }))

    }


    func fetch() {
        dataSource = RLMSubject().findAll()
        sortBy(.firstName)
        delegate?.didFetchDataSource()
    }


    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item] {
        let model = dataSource?[indexPath.row]
        //TODO: correct logic
        let isSubmitted = indexPath.row % 2 == 0

        return [
            .imageButton(options: .init(action: { [weak self] view, options, index in
                let items = RLMLogChooseRow().findAll()

                let picker = SingleValuePickerView(values: items)
                picker.backgroundColor = .white

                guard let toolbar = self?.defaultToolbarView(onDone: {
                    guard let subject = self?.dataSource?[indexPath.row],
                        let row = picker.selectedValue?.row else {
                            return
                    }

                    self?.delegate?.customResponder?.resignFirstResponder()

                    let logForm: RLMLogForm

                    if let form = RLMLogForm().find(withSubjectID: subject.id) {
                        logForm = form
                    } else {
                        logForm = RLMLogForm()
                        logForm.subject = subject
                        logForm.create()
                    }

                    logForm.writeTransaction {
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
