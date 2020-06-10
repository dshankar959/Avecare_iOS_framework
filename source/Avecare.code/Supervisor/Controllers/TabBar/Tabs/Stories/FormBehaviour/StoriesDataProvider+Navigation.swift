import Foundation
import CocoaLumberjack

protocol StoriesDataProviderNavigation {
    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item]
}

extension StoriesDataProvider: StoriesDataProviderNavigation {

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
                self?.delegate?.showError(title: NSLocalizedString("alert_notitle_story_title", comment: ""), message: NSLocalizedString("alert_notitle_story_message", comment: ""))
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

        // TODO: show loader
        UnitAPIService.publishStory(model) { [weak self] result in
            switch result {
            case .success:
                // update UI to block editing
                // story will be moved to 1st position after sort()
                // because serverDate updated
                let newPosition = IndexPath(row: 0, section: 0)
                guard let index = self?.dataSource.firstIndex(of: story) else {
                    return
                }
                let currentPosition = IndexPath(row: index, section: 0)

                //  update serverDate
                RLMStory.writeTransaction {
                    let date = Date() // FIXME: should be date from server response?
                    story.clientLastUpdated = date
                    story.serverLastUpdated = date
                    story.publishState = .published
                }

                self?.sort()
                self?.delegate?.moveStory(at: currentPosition, to: newPosition)
                self?.delegate?.didUpdateModel(at: newPosition, details: true)
            case .failure(let error):
                DDLogError("\(error)")
            }
        }
    }
}
