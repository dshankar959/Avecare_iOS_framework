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

        pdfView.leadingAnchor.constraint(equalTo: innerView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: innerView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: innerView.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: innerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pdfView.backgroundColor =  UIColor.white
        
        // Adding the thumnails
        let thumbnailView = PDFThumbnailView()
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(thumbnailView)

        thumbnailView.leadingAnchor.constraint(equalTo: innerView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: innerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        thumbnailView.topAnchor.constraint(equalTo: innerView.safeAreaLayoutGuide.topAnchor).isActive = true
        thumbnailView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        thumbnailView.backgroundColor = UIKit.UIColor(resource: R.color.background, compatibleWith: nil) ?? UIColor.white
        thumbnailView.thumbnailSize = CGSize(width: 70, height: 70)
        thumbnailView.layoutMode = .vertical
        thumbnailView.pdfView = pdfView
        if let url = url, let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
}
