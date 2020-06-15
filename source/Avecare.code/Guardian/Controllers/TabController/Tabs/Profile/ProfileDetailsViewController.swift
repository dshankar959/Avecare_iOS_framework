import UIKit
import WebKit
import PDFKit
import CocoaLumberjack


enum ProfileDetails {
    case mealPlan
//    case activities
}


class ProfileDetailsViewController: UIViewController, IndicatorProtocol, WKNavigationDelegate {

    var profileDetails: ProfileDetails = .mealPlan

    var attachmentURL: String? // From feed details

    override func viewDidLoad() {

        super.viewDidLoad()
        if let attachmentURL = attachmentURL {
            loadContentforAttachment(attachmentURL: attachmentURL )
        } else if let institution = RLMInstitution.findAll().first {
            if let fileURL = institution.mealPlanURL(using: DocumentService()) {
                loadPDFWithLink(url: fileURL)
            }
        }
    }

    func loadPDFWithLink(url: URL) {
        
        let pdfView = PdfView()
        self.view.addSubview(pdfView)
        pdfView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        pdfView.loadPDFat(url: url)
    }

    private func loadContentforAttachment(attachmentURL: String) {
        
        let webView: WKWebView = WKWebView(frame: CGRect.zero)
        webView.frame = view.frame
        view.addSubview(webView)
        webView.navigationDelegate = self
        showActivityIndicator(withStatus: NSLocalizedString("profile_details_loading", comment: ""))
        if let contentURL = URL(string: attachmentURL) {
            webView.load(URLRequest(url: contentURL))
        } else {
            let error = FileError.fileNotFound.message
            showErrorAlert(error)
            DDLogError("\(error)")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideActivityIndicator()
    }

}
