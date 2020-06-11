import Foundation
import CocoaLumberjack



extension StoriesTableViewCellModel {

    init(story: RLMStory, storage: DocumentService) {
        title = story.title
//        details = story.body
        documentURL = story.pdfURL(using: storage)
//        photoCaption = story.photoCaption

        if let lastUpdated = story.clientLastUpdated {
            date = lastUpdated
        } else if let lastUpdated = story.serverLastUpdated {
            date = lastUpdated
        } else {
            fatalError("Story missing dateTime stamp.  :(")
        }
    }

}


protocol StoriesDataProviderDelegate: UIViewController {
    func showError(title: String, message: String)
    func didCreateNewStory()
    func didUpdateModel(at indexPath: IndexPath, details: Bool)
    func moveStory(at fromIndexPath: IndexPath, to toIndexPath: IndexPath)
    func didTapPDF(story: RLMStory, view: PDFThumbView)
    func gotToPDFDetail(fileUrl: URL)
}


protocol StoriesDataProviderIO: class, StoriesDataProviderNavigation {
    var delegate: StoriesDataProviderDelegate? { get set }

    func fetchAll()
    var numberOfRows: Int { get }
    func isRowStoryPublished(at indexPath: IndexPath) -> Bool
    func model(for indexPath: IndexPath) -> StoriesTableViewCellModel
    func setSelected(_ isSelected: Bool, at indexPath: IndexPath)
    func removeStoryAt(at indexPath: IndexPath)

    func form(at indexPath: IndexPath) -> Form
    func didPickDocumentsAt(urls: [URL], view: PDFThumbView)

}


class StoriesDataProvider: StoriesDataProviderIO {
   
    func isRowStoryPublished(at indexPath: IndexPath) -> Bool {
        let story = dataSource[indexPath.row]
        return story.publishState != .local
    }

    func isRowStoryPublished(at indexPath: IndexPath) -> Bool {
        let story = dataSource[indexPath.row]
        return story.publishState != .local
    }



    var selectedStory: RLMStory?
    var delegate: StoriesDataProviderDelegate?

    var dataSource = [RLMStory]()
    let imageStorageService = DocumentService()


    func fetchAll() {
        dataSource = RLMStory.findAll()
        if dataSource.count == 0 {
            createNewStory()
        } else {
            sort()
        }
    }

    func removeStoryAt( at indexPath: IndexPath) {
        let story = dataSource[indexPath.row]
        story.clean()
        // no need to fetch all stories again.
        dataSource.remove(at: indexPath.row)
    }

    func sort() {
        dataSource = RLMLogForm.sortObjectsByLastUpdated(order: .orderedDescending, dataSource)
    }

    var numberOfRows: Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> StoriesTableViewCellModel {
        let story = dataSource[indexPath.row]
        var viewModel = StoriesTableViewCellModel(story: story, storage: imageStorageService)
        viewModel.isSelected = story.id == selectedStory?.id
        return viewModel
    }

    func setSelected(_ isSelected: Bool, at indexPath: IndexPath) {
        let targetId = dataSource[indexPath.row].id
        let last = selectedStory?.id
        // update new selection
        selectedStory = dataSource[indexPath.row]

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
           // bodyViewModel(for: story),
            getPDFThumbViewModel(for: story).inset(by: .init(top: 20, left: 0, bottom: 0, right: 0))
        ])
    }

    func updateEditDate(for story: RLMStory) {
        RLMStory.writeTransaction {
            story.clientLastUpdated = Date()
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
