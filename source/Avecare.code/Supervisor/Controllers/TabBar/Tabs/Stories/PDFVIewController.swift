import UIKit
import Foundation
import PDFKit

class PDFVIewController: UIViewController {

    var url: URL?

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
}
