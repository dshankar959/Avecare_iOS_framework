import UIKit

class FeedDetailsViewController: UIViewController {
    var feedItemType: FeedItemType?
    var feedItemId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveDetails()
    }

    private func retrieveDetails() {
        if feedItemType == .message, let messageId = feedItemId {
            //
        }
    }
}
