import UIKit



class FeedDetailsViewController: UIViewController, IndicatorProtocol {

    var feedItemType: FeedItemType?
    var feedItemId: String?

    let dataProvider: FeedDetailsDataProvider = DefaultFeedDetailsDataProvider()

    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var senderCategoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var attachmentButton: UIButton!

    private var fileURL: String?


    override func viewDidLoad() {
        super.viewDidLoad()

        attachmentButton.setTitle("file-download", for: .normal)
        retrieveDetails()
    }

    private func retrieveDetails() {
        if feedItemType == .message, let messageId = feedItemId {
            showActivityIndicator(withStatus: NSLocalizedString("feed_details_retriving_message", comment: ""))
            dataProvider.fetchMessage(with: messageId) { (message, error) in
                self.hideActivityIndicator()
                if let error = error {
                    self.showErrorAlert(error)
                } else if let message = message {
                    self.titleLabel.text = message.title

                    if let serverLastUpdated = message.serverLastUpdated {
                        self.dateLabel.text = serverLastUpdated.dateStringFromDate()
                    } else {
                        self.dateLabel.text = message.createdAt.dateStringFromDate()
                    }

                    self.bodyLabel.text = message.body
                    if let fileURL =  message.fileURL {
                        self.fileURL = fileURL
                        self.attachmentButton.isEnabled = true
                    } else {
                        self.attachmentButton.isEnabled = false
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.feedDetailsViewController.attachment.identifier,
            let destination = segue.destination as? ProfileDetailsViewController {
            destination.attachmentURL = fileURL
        }
    }

}
