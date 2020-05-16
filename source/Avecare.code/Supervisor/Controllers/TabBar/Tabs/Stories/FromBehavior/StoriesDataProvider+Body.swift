import Foundation
import UIKit

extension StoriesDataProvider {
    func bodyViewModel(for story: RLMStory) -> FormTextViewModel {
        let subtitleFont: UIFont = .systemFont(ofSize: 14)
        return FormTextViewModel(font: subtitleFont, placeholder: "Begin typing here.",
                value: story.body, isEditable: story.serverDate == nil, onChange: { [weak self] _, textValue in
            RLMStory.writeTransaction {
                story.body = textValue ?? ""
            }
            // update date
            self?.updateEditDate(for: story)
        })
    }
}
