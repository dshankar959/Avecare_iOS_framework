import Foundation
import CocoaLumberjack



protocol StoriesDataProviderNavigation {
    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item]
}


extension StoriesDataProvider: StoriesDataProviderNavigation, IndicatorProtocol {

    // DO NOT USE INDEX PATH IN BLOCKS AS ORDER MAY CHANGE
    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item] {
        let story = dataSource[indexPath.row]
        let isSubmitted = story.publishState != .local

        let isStorySubmitable = DocumentService().fileURL(name: story.id, type: "pdf") != nil
        let isEnabled = !isSubmitted && isStorySubmitable
        let publishText = isSubmitted ? "Published" : "Publish"
        let publishColor = isEnabled ? R.color.main() :R.color.lightText4()
        return [
            .imageButton(options: .init(action: { [weak self] view, options, index in
                self?.createNewStory()
            }, isEnabled: true, image: R.image.plusIcon())),
            .offset(value: 10),
            // Navigation Bar -> Publish selected story
            .button(options: .init(action: { [weak self] view, options, index in
                if story.title.isEmpty {
                    self?.delegate?.showError(title: NSLocalizedString("alert_notitle_story_title", comment: ""),
                                              message: NSLocalizedString("alert_notitle_story_message", comment: ""))
                    return
                }
                self?.publishStory(story)
            }, isEnabled: isEnabled, text: publishText, textColor: R.color.mainInversion(),
                    tintColor: publishColor, cornerRadius: 4))

        ]
    }

    func createNewStory() {
        guard let unitId = RLMSupervisor.details?.primaryUnitId,
                let unit = RLMUnit.find(withID: unitId) else {
            return
        }

        let story = RLMStory(id: newUUID)
        story.unit = unit
        story.create()
        dataSource.insert(story, at: 0)
        delegate?.didCreateNewStory()
    }

    func publishStory(_ story: RLMStory) {
        guard let unitId = RLMSupervisor.details?.primaryUnitId else {
            return
        }

        RLMStory.writeTransaction {
            story.clientLastUpdated = Date()
            story.publishState = .publishing
        }

        let model = PublishStoryRequestModel(unitId: unitId, story: story, storage: imageStorageService)

        showActivityIndicator(withStatus: NSLocalizedString("publishing_status", comment: ""))
        UnitAPIService.publishStory(model) { [weak self] result in
            switch result {
            case .success(let response):
                self?.hideActivityIndicator()
                // update UI to block editing
                var row = (self?.dataSource.count ?? 0) - 1
                if let dSource = self?.dataSource, let firstPublished = self?.dataSource.first(where: { $0.rawPublishState == 2 }) {
                    row = (dSource.firstIndex(of: firstPublished)  ?? 0) - 1
                }
                row = (row < 0) ? 0 : row
                // new position for a subimitted story has to be after all the unpublished ones
                let newPosition = IndexPath(row: row, section: 0)
                guard let index = self?.dataSource.firstIndex(of: story) else {
                    return
                }
                let currentPosition = IndexPath(row: index, section: 0)

                //  update serverDate
                RLMStory.writeTransaction {
                    story.serverLastUpdated = response.serverLastUpdated
                    story.publishState = .published
                }

                self?.delegate?.didUpdateModel(at: currentPosition, details: true)
                self?.sort()
                self?.delegate?.moveStory(at: currentPosition, to: newPosition)
                
            case .failure(let error):
                self?.hideActivityIndicator()
                DDLogError("\(error)")
            }
        }

    }

}
