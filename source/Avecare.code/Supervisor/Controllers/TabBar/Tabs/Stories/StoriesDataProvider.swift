import Foundation
import CocoaLumberjack

extension StoriesTableViewCellModel {
    init(story: RLMStory, imageStorage: ImageStorageService) {
        title = story.title
        date = story.localDate
        details = story.body
        photoURL = story.photoURL(using: imageStorage)
        photoCaption = story.photoCaption
    }
}

protocol StoriesDataProviderDelegate: UIViewController {
    func didCreateNewStory()
    func didUpdateModel(at indexPath: IndexPath, details: Bool)
    func moveStory(at fromIndexPath: IndexPath, to toIndexPath: IndexPath)
}

protocol StoriesDataProviderIO: class, StoriesDataProviderNavigation {
    var delegate: StoriesDataProviderDelegate? { get set }

    func fetchAll()

    var numberOfRows: Int { get }

    func model(for indexPath: IndexPath) -> StoriesTableViewCellModel
    func setSelected(_ isSelected: Bool, at indexPath: IndexPath)

    func form(at indexPath: IndexPath) -> Form
}

class StoriesDataProvider: StoriesDataProviderIO {

    private var selectedStoryId: String?
    var delegate: StoriesDataProviderDelegate?

    var dataSource = [RLMStory]()
    let imageStorageService = ImageStorageService()

    func fetchAll() {
        dataSource = RLMStory.findAll()
        if dataSource.count == 0 {
            createNewStory()
        } else {
            sort()
        }
    }

    func sort() {
        dataSource.sort { story1, story2 in
            let date1 = story1.serverDate ?? story1.localDate
            let date2 = story2.serverDate ?? story2.localDate
            return date1 > date2
        }
    }

    var numberOfRows: Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> StoriesTableViewCellModel {
        let story = dataSource[indexPath.row]
        var viewModel = StoriesTableViewCellModel(story: story, imageStorage: imageStorageService)
        viewModel.isSelected = story.id == selectedStoryId
        return viewModel
    }

    func setSelected(_ isSelected: Bool, at indexPath: IndexPath) {
        let targetId = dataSource[indexPath.row].id
        let last = selectedStoryId
        // update new selection
        selectedStoryId = targetId

        // update previous selection
        if let last = last, last != targetId,
           let index = dataSource.firstIndex(where: { $0.id == last }) {
            delegate?.didUpdateModel(at: IndexPath(row: index, section: 0), details: false)
        }
        delegate?.didUpdateModel(at: indexPath, details: true)
    }

    func form(at indexPath: IndexPath) -> Form {
        let story = dataSource[indexPath.row]
        return Form(viewModels: [
            titleViewModel(for: story),
            subtitleViewModel(for: story).inset(by: .init(top: 20, left: 0, bottom: 20, right: 0)),
            bodyViewModel(for: story),
            photoViewModel(for: story).inset(by: .init(top: 20, left: 0, bottom: 0, right: 0))
        ])
    }

    func updateEditDate(for story: RLMStory) {
        RLMStory.writeTransaction {
            story.localDate = Date()
        }

        guard let startIndex = dataSource.firstIndex(of: story) else {
            return
        }
        sort()

        guard let endIndex = dataSource.firstIndex(of: story), startIndex != endIndex else {
            return
        }

        delegate?.moveStory(at: IndexPath(row: startIndex, section: 0),
                to: IndexPath(row: endIndex, section: 0))
    }
}
