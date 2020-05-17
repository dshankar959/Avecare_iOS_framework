import Foundation

extension StoriesDataProvider {
    func subtitleViewModel(for story: RLMStory) -> FormLabelViewModel {
        let formatter = Date.shortMonthTimeFormatter

        if let date = story.serverLastUpdated {
            let time = formatter.string(from: date)
            return FormLabelViewModel.subtitle("Published - \(time)")
        } else {
            let time = formatter.string(from: story.clientLastUpdated)
            return FormLabelViewModel.subtitle("Last saved - \(time)")
        }
    }
}
