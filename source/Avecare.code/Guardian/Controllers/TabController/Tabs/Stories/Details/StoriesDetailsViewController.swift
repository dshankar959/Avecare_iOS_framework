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
            }
        }
    }
}
