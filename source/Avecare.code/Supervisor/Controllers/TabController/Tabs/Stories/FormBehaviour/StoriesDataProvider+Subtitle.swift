import Foundation



extension StoriesDataProvider {

    func subtitleViewModel(for story: RLMStory) -> LabelFormViewModel {
        let formatter = Date.fullMonthTimeFormatter

        let prefix = story.publishState == .local ? "Last updated" : "Published"
        let time = formatter.string(from: (story.clientLastUpdated ?? story.serverLastUpdated) ?? Date())
        return LabelFormViewModel.subtitle("\(prefix) - \(time)")
    }

}
