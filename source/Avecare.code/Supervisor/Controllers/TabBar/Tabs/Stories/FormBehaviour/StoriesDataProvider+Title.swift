import Foundation
import UIKit

extension StoriesDataProvider {
    func titleViewModel(for story: RLMStory) -> FormTextViewModel {
        let titleFont: UIFont = .systemFont(ofSize: 36)

        let isSubmitted = story.publishState != .local
        return FormTextViewModel(font: titleFont, placeholder: "Type Your Story Title Here",
                value: story.title, isEditable: !isSubmitted, onChange: { [weak self] _, textValue in
            RLMStory.writeTransaction {
                story.title = textValue ?? ""
            }
            // update date
            // side menu row will be moved to 1st position
            self?.updateEditDate(for: story)
            // update title on side list row
            self?.delegate?.didUpdateModel(at: IndexPath(row: 0, section: 0), details: true)
        })
    }
}
