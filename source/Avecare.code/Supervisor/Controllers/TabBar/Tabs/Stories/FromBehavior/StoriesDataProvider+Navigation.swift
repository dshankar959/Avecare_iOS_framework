import Foundation
import CocoaLumberjack

protocol StoriesDataProviderNavigation {
    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item]
}

extension StoriesDataProvider: StoriesDataProviderNavigation {

    // DO NOT USE INDEX PATH IN BLOCKS AS ORDER MAY CHANGE
    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item] {
        let story = dataSource[indexPath.row]
        let isSubmitted = story.serverDate != nil

        let publishText = isSubmitted ? "Published" : "Publish"
        let publishColor = isSubmitted ? R.color.lightText4() : R.color.main()

        return [
            .imageButton(options: .init(action: { [weak self] view, options, index in
                self?.createNewStory()
            }, isEnabled: true, image: R.image.plusIcon())),
            .offset(value: 10),
            // Navigation Bar -> Publish selected story
            .button(options: .init(action: { [weak self] view, options, index in
                self?.publishStory(story)
            }, isEnabled: !isSubmitted, text: publishText, textColor: R.color.mainInversion(),
                    tintColor: publishColor, cornerRadius: 4))

        ]
    }

    func createNewStory() {
        let story = RLMStory(id: newUUID)
        story.create()
        dataSource.insert(story, at: 0)
        delegate?.didCreateNewStory()
    }

    func publishStory(_ story: RLMStory) {
        guard let unitId = RLMSupervisor.details?.primaryUnitId else {
            return
        }
        let publishAt = Date()
        let model = StoryAPIModel(unitId: unitId, story: story, date: publishAt, storage: imageStorageService)

        UnitAPIService.publishStory(model) { [weak self] result in
            switch result {
            case .success(let filesList):
                // link remote image url to story
                // & update serverDate
                RLMStory.writeTransaction {
                    story.remoteImageURL = filesList.files.first?.fileUrl
                    story.serverDate = publishAt
                }

                // TODO: we can add local image to Kingfisher cache to avoid loading from remote

                // remove local image as we going to use remote link
                if let service = self?.imageStorageService,
                   let url = service.imageURL(name: story.id) {
                    try? service.removeImage(at: url)
                }

                // update UI to block editing
                // story will be moved to 1st position after sort()
                // because serverDate updated
                let newPosition = IndexPath(row: 0, section: 0)
                guard let index = self?.dataSource.firstIndex(of: story) else {
                    return
                }
                self?.sort()
                self?.delegate?.moveStory(at: IndexPath(row: index, section: 0), to: newPosition)
                self?.delegate?.didUpdateModel(at: newPosition, details: true)
            case .failure(let error):
                DDLogError("\(error)")
            }
        }
    }
}