import Foundation

extension StoriesDataProvider {
    func subtitleViewModel(for story: RLMStory) -> FormLabelViewModel {
        let formatter = Date.shortMonthTimeFormatter

        let prefix = story.publishState == .local ? "Last saved" : "Published"
        let time = formatter.string(from: story.clientLastUpdated ?? Date())
        return FormLabelViewModel.subtitle("\(prefix) - \(time)")
    }
}
