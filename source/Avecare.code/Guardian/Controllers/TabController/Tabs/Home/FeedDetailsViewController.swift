import UIKit



class FeedDetailsViewController: UIViewController, IndicatorProtocol {

    var feedTitle: String?
    var feedItemType: FeedItemType?
    var feedItemId: String?

    let dataProvider: FeedDetailsDataProvider = DefaultFeedDetailsDataProvider()

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconImageHeight: NSLayoutConstraint!
    @IBOutlet weak var iconImageWidth: NSLayoutConstraint!
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
        senderNameLabel.text = feedTitle
        retrieveDetails()
    }

    private func retrieveDetails() {
        showActivityIndicator(withStatus: NSLocalizedString("feed_details_retrieving_message", comment: ""))
        if feedItemType == .message, let messageId = feedItemId {
            dataProvider.fetchMessage(with: messageId) { [weak self] (message, error) in
                self?.hideActivityIndicator()
                if let error = error {
                    self?.showErrorAlert(error)
                } else {
                    self?.iconImage.image = R.image.navLogoIcon()
                    self?.senderCategoryLabel.text = message?.header
                    self?.titleLabel.text = message?.title
                    self?.dateLabel.text = message?.serverLastUpdated?.dateString
                    self?.bodyLabel.text = message?.body

                    if let fileURL =  message?.fileURL {
                        self?.fileURL = fileURL
                        self?.attachmentButton.isHidden = false
                    } else {
                        self?.attachmentButton.isHidden = true
                    }
                }
            }
        } else if feedItemType == .unitActivity, let activityId = feedItemId {
            dataProvider.fetchActivity(with: activityId) { [weak self] (activity, error) in
                self?.hideActivityIndicator()
                if let error = error {
                    self?.showErrorAlert(error)
                } else {
                    var bodyText = activity?.activityOption?.descriptions
                    bodyText?.append("\n\n")
                    bodyText?.append(activity?.instructions ?? "")

                    self?.bodyLabel.text = bodyText
                    self?.setTexts(withSender: activity?.unit?.name,
                                   title: activity?.activityOption?.name,
                                   date: activity?.activityDate?.dateString,
                                   andBody: bodyText)

                    self?.attachmentButton.isHidden = true
                }
            }
        } else if feedItemType == .subjectInjury, let injuryId = feedItemId {
            dataProvider.fetchInjury(with: injuryId) { [weak self] (injury, error) in
                self?.hideActivityIndicator()
                if let error = error {
                    self?.showErrorAlert(error)
                } else {
                    self?.setIcon(withImage: R.image.exclamationIcon(), andColor: R.color.redIcon())

                    var bodyText = injury?.injuryOption?.descriptions
                    bodyText?.append("\n\n")
                    bodyText?.append(injury?.message ?? "")
                    self?.bodyLabel.text = bodyText
                    self?.setTexts(withSender: injury?.subject?.fullName,
                                   title: injury?.injuryOption?.name,
                                   date: injury?.timeOfInjury?.dateTimeString,
                                   andBody: bodyText)

                    self?.attachmentButton.isHidden = true
                }
            }
        } else if feedItemType == .subjectReminder, let reminderId = feedItemId {
            dataProvider.fetchReminder(with: reminderId) { [weak self] (reminder, error) in
                self?.hideActivityIndicator()
                if let error = error {
                    self?.showErrorAlert(error)
                } else {
                    self?.setIcon(withImage: R.image.clockIcon(), andColor: R.color.blueIcon())

                    var bodyText = reminder?.reminderOption?.descriptions
                    bodyText?.append("\n\n")
                    bodyText?.append(reminder?.message ?? "")

                    self?.setTexts(withSender: reminder?.subject?.fullName,
                                   title: reminder?.reminderOption?.name,
                                   date: reminder?.serverLastUpdated?.dateString,
                                   andBody: bodyText)

                    self?.attachmentButton.isHidden = true
                }
            }
        } else {
            hideActivityIndicator()
        }
    }

    private func setIcon(withImage image: UIImage?, andColor color: UIColor?) {
        iconImageWidth.constant = 40
        iconImageHeight.constant = 40
        iconImage.layer.cornerRadius = 10
        iconImage.clipsToBounds = true
        iconImage.contentMode = .center
        iconImage.image = image
        iconImage.backgroundColor = color?.withAlphaComponent(0.3)
        iconImage.tintColor = color
    }

    private func setTexts(withSender senderString: String?,
                          title titleString: String?,
                          date dateString: String?,
                          andBody bodyString: String?) {
        senderCategoryLabel.text = senderString
        titleLabel.text = titleString
        dateLabel.text = dateString
        bodyLabel.text = bodyString
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.feedDetailsViewController.attachment.identifier,
            let destination = segue.destination as? ProfileDetailsViewController {
            destination.attachmentURL = fileURL
        }
    }
}
