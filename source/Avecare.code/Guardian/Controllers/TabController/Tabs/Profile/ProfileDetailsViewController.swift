import UIKit
import WebKit
import CocoaLumberjack


enum ProfileDetails {
    case mealPlan
//    case activities
}


class ProfileDetailsViewController: UIViewController, IndicatorProtocol, WKNavigationDelegate {

    var profileDetails: ProfileDetails = .mealPlan
    private let webView: WKWebView = WKWebView(frame: CGRect.zero)

    var attachmentURL: String? // From feed details

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = view.frame
        view.addSubview(webView)
        webView.navigationDelegate = self
        loadContent()
    }

    private func loadContent() {
        if let attachmentURL = attachmentURL {
            showActivityIndicator(withStatus: NSLocalizedString("profile_details_loading", comment: ""))
            if let contentURL = URL(string: attachmentURL) {
                webView.load(URLRequest(url: contentURL))
            } else {
                let error = FileError.fileNotFound.message
                showErrorAlert(error)
                DDLogError("\(error)")
            }

        } else if let institution = RLMInstitution.findAll().first {
            let fileURL: URL?
            switch profileDetails {
            case .mealPlan:
                fileURL = institution.mealPlanURL(using: DocumentService())
//            case .activities:
//                fileURL = institution.activityURL(using: DocumentService())
            }

            if let fileURL = fileURL {
                showActivityIndicator(withStatus: NSLocalizedString("profile_details_loading", comment: ""))
                webView.load(URLRequest(url: fileURL))
            } else {
                let error = FileError.fileNotFound.message
                showErrorAlert(error)
                DDLogError("\(error)")
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideActivityIndicator()
    }

}
