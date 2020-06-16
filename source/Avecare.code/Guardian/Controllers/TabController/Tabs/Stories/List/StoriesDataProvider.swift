import Foundation



protocol StoriesDataProvider: class {
    var unitIds: [String] { get set }
    func numberOfRows(for section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    func details(at indexPath: IndexPath) -> StoriesDetails
}


protocol SupervisorsDataProvider: class {
    var unitIds: [String] { get set }
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> SupervisorCollectionViewCellModel
}


class DefaultSupervisorsDataProvider: SupervisorsDataProvider {

    private let supervisors = RLMSupervisor.findAll()
    private let storage = DocumentService()

    private var dataSource = [RLMSupervisor]()

    var unitIds: [String] = [] {
        didSet {
            if unitIds.count > 0 {
                dataSource = filter(for: supervisors, with: unitIds)
            } else {
                dataSource = supervisors
            }
        }
    }


    private func filter(for supervisors: [RLMSupervisor], with unitIds: [String]) -> [RLMSupervisor] {
        var result = [RLMSupervisor]()
        unitIds.forEach { unitId in
            let filteredSupervisors = supervisors.filter { $0.primaryUnitId == unitId }
            result.append(contentsOf: filteredSupervisors)
        }
        return result
    }


    var numberOfRows: Int {
        return dataSource.count
    }


    func model(for indexPath: IndexPath) -> SupervisorCollectionViewCellModel {
        return SupervisorCollectionViewCellModel(with: dataSource[indexPath.row], storage: storage)
    }

}



extension SupervisorCollectionViewCellModel {

    init(with educator: RLMSupervisor, storage: DocumentService) {
        id = educator.id

        let titleString: String
        if educator.title.count > 0 {
            titleString = educator.title
        } else {
            titleString = "Ms."
        }
        title = titleString

        name = educator.lastName
        photo = educator.photoURL(using: storage)
    }

}


class DefaultStoriesDataProvider: StoriesDataProvider {

    private let supervisors = DefaultSupervisorsDataProvider()
    private let stories = RLMStory.findAll()
    private let storage = DocumentService()

    func sort() {
        dataSource = RLMLogForm.sortObjectsByLastUpdated(order: .orderedDescending, dataSource)
    }

    private var dataSource = [RLMStory]()

    var unitIds = [String]() {
        didSet {
            supervisors.unitIds = unitIds

            if unitIds.count > 0 {
                dataSource = filter(for: stories, with: unitIds)
            } else {
                dataSource = stories
                sort()
            }
        }
    }


    private func filter(for stories: [RLMStory], with unitIds: [String]) -> [RLMStory] {
        var result = [RLMStory]()
        unitIds.forEach { unitId in
            let filteredStories = stories.filter { $0.unit?.id == unitId }
            result.append(contentsOf: filteredStories)
        }
        return result
    }

    func numberOfRows(for section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return dataSource.count
        default: return 0
        }
    }


    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        switch indexPath.section {
        case 0: return SupervisorFilterTableViewCellModel(dataProvider: supervisors)
        case 1: return StoriesTableViewCellModel(with: dataSource[indexPath.row], storage: storage)
        default: fatalError()
        }
    }


    func details(at indexPath: IndexPath) -> StoriesDetails {
        guard indexPath.section == 1 else { fatalError() }
        let parent = dataSource[indexPath.row]
        let pdfURL = parent.pdfURL(using: storage)
        return StoriesDetails(title: parent.title, pdfURL: pdfURL, date: parent.serverLastUpdated)
    }

}


extension StoriesTableViewCellModel {

    init(with story: RLMStory, storage: DocumentService) {
        isPublished = true
        title = story.title
        date = story.serverLastUpdated ?? Date()
        documentURL = story.pdfURL(using: storage)
    }

}
