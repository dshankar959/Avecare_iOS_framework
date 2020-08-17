import UIKit
import WebKit
import PDFKit
import CocoaLumberjack


enum ProfileDetails {
    case mealPlan
}


class ProfileDetailsViewController: UIViewController, IndicatorProtocol, WKNavigationDelegate {

    var profileDetails: ProfileDetails = .mealPlan
    var attachmentURL: String? // From feed details


    override func viewDidLoad() {
        super.viewDidLoad()

        if let attachmentURL = attachmentURL {
            loadContentforAttachment(attachmentURL: attachmentURL )
             self.navigationItem.rightBarButtonItem = nil

        } else if let institution = RLMInstitution.findAll().first {
            if let fileURL = institution.mealPlanURL(using: DocumentService()) {
               self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style:
                UIBarButtonItem.Style.plain, target: self, action: #selector(pdfSavePressed))

                let textAttributes = [
                NSAttributedString.Key.font: UIFont(name: "FontAwesome5Pro-Solid", size: 22.0)!]

                self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(textAttributes, for: .normal)
                self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(textAttributes, for: .selected)

                loadPDFdocument(url: fileURL)
            }
        }
    }

    @objc func pdfSavePressed() {
        if let institution = RLMInstitution.findAll().first {
            if let tempLocalUrl = institution.mealPlanURL(using: DocumentService()) {

                let activityViewController = UIActivityViewController(activityItems: [tempLocalUrl], applicationActivities: nil)

                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            }

            activityViewController.excludedActivityTypes = [.airDrop,
                                                            .addToReadingList,
                                                            .assignToContact,
                                                            .copyToPasteboard,
                                                            .mail,
                                                            .mail,
                                                            .message,
                                                            .openInIBooks,
                                                            .postToFacebook,
                                                            .postToFlickr,
                                                            .postToTencentWeibo,
                                                            .postToVimeo,
                                                            .postToTencentWeibo,
                                                            .postToTwitter,
                                                            .print]
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }

    private func loadPDFdocument(url: URL) {
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
