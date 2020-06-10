import UIKit
import Foundation
import PDFKit

class PDFVIewController: UIViewController {

    var url: URL?

    @IBOutlet weak var innerView: UIView!
    @IBAction func goBack(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let pdfView = PDFView()

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)

        pdfView.backgroundColor =  UIColor.white
        pdfView.autoScales = true

        // Adding the thumnails
        let thumbnailView = PDFThumbnailView()
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(thumbnailView)

        thumbnailView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        thumbnailView.backgroundColor = UIKit.UIColor(resource: R.color.background, compatibleWith: nil) ?? UIColor.white
        thumbnailView.thumbnailSize = CGSize(width: 70, height: 70)

        pdfView.snp.makeConstraints { (make) in
            make.top.equalTo(self.innerView.snp.top).offset(0)
            make.bottom.equalTo(self.innerView.snp.bottom).offset(0)
            make.leading.equalTo(self.innerView.snp.leading).offset(90)
            make.trailing.equalTo(self.innerView.snp.trailing).offset(0)
        }
        thumbnailView.snp.makeConstraints { (make) in
            make.top.equalTo(self.innerView.snp.top).offset(0)
            make.bottom.equalTo(self.innerView.snp.bottom).offset(0)
            make.leading.equalTo(self.innerView.snp.leading).offset(0)
            make.trailing.equalTo(pdfView.snp.leading).offset(0)
        }
        thumbnailView.pdfView = pdfView
        if let url = url, let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
}
