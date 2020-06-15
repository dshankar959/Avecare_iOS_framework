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
        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        pdfView.backgroundColor =  UIColor.white
        pdfView.autoScales = true

        // Adding the thumnails
        let thumbnailView = PDFThumbnailView()
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.layoutMode = .vertical
        view.addSubview(thumbnailView)
        
        thumbnailView.backgroundColor = UIKit.UIColor(resource: R.color.background, compatibleWith: nil) ?? UIColor.white
        thumbnailView.thumbnailSize = CGSize(width: 70, height: 70)
        
        pdfView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(0)
            make.bottom.equalTo(self.view.snp.bottom).offset(0)
            make.leading.equalTo(self.view.snp.leading).offset(90)
            make.trailing.equalTo(self.view.snp.trailing).offset(0)
        }
        
        thumbnailView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(0)
            make.bottom.equalTo(self.view.snp.bottom).offset(0)
            make.leading.equalTo(self.view.snp.leading).offset(0)
            make.trailing.equalTo(pdfView.snp.leading).offset(0)
        }
        thumbnailView.pdfView = pdfView
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
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
