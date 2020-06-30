import UIKit



enum AboutDetails: String, CaseIterable {
    case termsAndConditions = "profile_about_details_terms_and_conditions"
    case privacyPolicy = "profile_about_details_privacy_policy"
}


class AboutDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    var aboutDetails: AboutDetails = .termsAndConditions

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = NSLocalizedString(aboutDetails.rawValue, comment: "")

        switch aboutDetails {
        case .termsAndConditions:
            contentLabel.text = "termsAndConditions"
        case .privacyPolicy:
            contentLabel.text = "privacyPolicy"
        }
    }


}
