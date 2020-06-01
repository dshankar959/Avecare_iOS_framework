import UIKit
import WebKit
import CocoaLumberjack


enum ProfileDetails {
    case mealPlan
//    case activities
}


class ProfileDetailsViewController: UIViewController, IndicatorProtocol, WKNavigationDelegate {

    var profileDetails: ProfileDetails = .mealPlan
    let webView: WKWebView = WKWebView(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        if let institution = RLMInstitution.findAll().first {
            let fileURL: URL?
            switch profileDetails {
            case .mealPlan:
                fileURL = institution.mealPlanURL(using: DocumentService())
//            case .activities:
//                fileURL = institution.activityURL(using: DocumentService())
            }

            if let fileURL = fileURL {
                webView.frame = view.frame
                view.addSubview(webView)
                webView.navigationDelegate = self

                showActivityIndicator(withStatus: NSLocalizedString("profile_details_loading", comment: ""))
                webView.load(URLRequest(url: fileURL))
            } else {
                let error = FileError.FileNotFound.message
                showErrorAlert(error)
                DDLogError("\(error)")
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideActivityIndicator()
    }

}
