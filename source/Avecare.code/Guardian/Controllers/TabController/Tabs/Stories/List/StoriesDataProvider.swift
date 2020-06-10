import Foundation

protocol StoriesDataProvider: class {
    var unitIds: [String] { get set }
    func numberOfRows(for section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    func details(at indexPath: IndexPath) -> StoriesDetails
}

protocol EducatorsDataProvider: class {
    var unitIds: [String] { get set }
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> SupervisorCollectionViewCellModel
}

class DefaultEducatorsDataProvider: EducatorsDataProvider {
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
    private let educators = DefaultEducatorsDataProvider()
    private let stories = RLMStory.findAll()
    private let storage = DocumentService()

    private var dataSource = [RLMStory]()

    var unitIds = [String]() {
        didSet {
            educators.unitIds = unitIds

            if unitIds.count > 0 {
                dataSource = filter(for: stories, with: unitIds)
            } else {
                dataSource = stories
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

//    var dataSource: [StoriesTableViewCellModel] = [
//        StoriesTableViewCellModel(title: "Colouring and Fine Motors Skills Development", date: Date(),
//                details: "1" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage1(),
//                photoCaption: "photo caption 1"),
//
//        StoriesTableViewCellModel(title: "Language Skills in the Classroom and at Home", date: Date(),
//                details: "2" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage2(),
//                photoCaption: "photo caption 2"),
//
//        StoriesTableViewCellModel(title: "Finger Painting - Classic Activities are Still Big Hits", date: Date(),
//                details: "3" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage3(),
//                photoCaption: "photo caption 3"),
//
//        StoriesTableViewCellModel(title: "Team Building Play", date: Date(),
//                details: "4" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage4(),
//                photoCaption: "photo caption 4"),
//
//        StoriesTableViewCellModel(title: "Our Little Artists with Big Imaginations", date: Date(),
//                details: "5" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage5(),
//                photoCaption: "photo caption 5"),
//
//        StoriesTableViewCellModel(title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit", date: Date(),
//                details: "6" + R.string.placeholders.lorem_large(), photo: R.image.placeholderImage6(),
//                photoCaption: "photo caption 6")
//    ]

    func numberOfRows(for section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return dataSource.count
        default: return 0
        }
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        switch indexPath.section {
        case 0: return SupervisorFilterTableViewCellModel(dataProvider: educators)
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
        title = story.title
        date = story.serverLastUpdated ?? Date()
        details = story.body
        pdfURL = story.pdfURL(using: storage)
        photoCaption = story.photoCaption
    }
}
