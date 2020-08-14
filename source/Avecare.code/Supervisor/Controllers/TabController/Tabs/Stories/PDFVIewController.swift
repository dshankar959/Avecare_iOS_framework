import UIKit
import Foundation
import PDFKit

class PDFVIewController: UIViewController {

    var url: URL?
    @IBOutlet weak var savePDFButton: UIButton!


    @IBOutlet weak var pdfView: PdfView!
    @IBAction func goBack(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            pdfView.loadPDFat(url: url)
        }
    }

    @IBAction func savePdfPressed(_ sender: Any) {
        if let tempLocalUrl = url {

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
