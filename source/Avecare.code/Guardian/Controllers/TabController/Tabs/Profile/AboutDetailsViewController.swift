import UIKit
import WebKit



enum AboutDetails: String, CaseIterable {
    case termsAndConditions = "profile_about_details_terms_and_conditions"
    case privacyPolicy = "profile_about_details_privacy_policy"
}


class AboutDetailsViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var aboutDetails: AboutDetails = .termsAndConditions

    override func viewDidLoad() {
        super.viewDidLoad()

        var url: URL?

        switch aboutDetails {
        case .termsAndConditions:
            url = URL(string: "https://avecare.ca/terms/")
        case .privacyPolicy:
            url = URL(string: "https://avecare.ca/privacy/")
        }

        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }

    }


}
