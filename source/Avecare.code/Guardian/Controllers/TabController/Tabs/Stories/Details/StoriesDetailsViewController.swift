import Foundation
import UIKit
import PDFKit
import SnapKit



protocol StoriesDetailsDataSource {
    func viewModels() -> [AnyCellViewModel]
}

struct StoriesDetails {

    let title: String
    let pdfURL: URL?
    let date: Date?
}


class StoriesDetailsViewController: UIViewController {

    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var pdfContainer: PdfView!

    var details: StoriesDetails?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let details = details {
            storyTitle.text = details.title
            if let date = details.date {
                dateTitleLabel.text = Date.monthDayYearFormatter.string(from: date)
            }
            if let url = details.pdfURL {
                pdfContainer.loadPDFat(url: url)
                addBarButtton()
            }
        }
    }

    func addBarButtton() {
           self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style:
            UIBarButtonItem.Style.plain, target: self, action: #selector(pdfSavePressed))
            let textAttributes = [
            NSAttributedString.Key.font: UIFont(name: "FontAwesome5Pro-Solid", size: 22.0)!]
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(textAttributes, for: .normal)
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(textAttributes, for: .selected)
    }

    @objc func pdfSavePressed() {
           if let tempLocalUrl = details?.pdfURL {

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
