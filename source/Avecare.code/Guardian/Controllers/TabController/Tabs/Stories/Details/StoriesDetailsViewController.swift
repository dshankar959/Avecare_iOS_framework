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
    @IBOutlet weak var pdfContainer: UIView!

    var details: StoriesDetails?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let details = details {
            storyTitle.text = details.title
            if let date = details.date {
                dateTitleLabel.text = Date.monthDayYearFormatter.string(from: date)
            }
            if let url = details.pdfURL {
                let pdfView = PDFView()

                pdfView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(pdfView)
                pdfView.autoScales = true
                pdfView.backgroundColor =  UIColor.white
                pdfView.autoScales = true

                let thumbnailView = PDFThumbnailView()
                thumbnailView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(thumbnailView)

                thumbnailView.backgroundColor = UIKit.UIColor(resource: R.color.background, compatibleWith: nil) ?? UIColor.white
                // check if ipad or iphone
                if hardwareDevice.isPad {
                    thumbnailView.thumbnailSize = CGSize(width: 70, height: 70)
                    thumbnailView.layoutMode = .vertical
                    pdfView.snp.makeConstraints { (make) in
                        make.top.equalTo(self.pdfContainer.snp.top).offset(0)
                        make.bottom.equalTo(self.pdfContainer.snp.bottom).offset(0)
                        make.leading.equalTo(self.pdfContainer.snp.leading).offset(90)
                        make.trailing.equalTo(self.pdfContainer.snp.trailing).offset(0)
                    }
                    thumbnailView.snp.makeConstraints { (make) in
                        make.top.equalTo(self.pdfContainer.snp.top).offset(0)
                        make.bottom.equalTo(self.pdfContainer.snp.bottom).offset(0)
                        make.leading.equalTo(self.pdfContainer.snp.leading).offset(0)
                        make.trailing.equalTo(pdfView.snp.leading).offset(0)
                    }
                } else {
                    thumbnailView.thumbnailSize = CGSize(width: 40, height: 40)
                    thumbnailView.layoutMode = .horizontal
                    pdfView.snp.makeConstraints { (make) in
                        make.top.equalTo(self.pdfContainer.snp.top).offset(0)
                        make.bottom.equalTo(self.pdfContainer.snp.bottom).offset(-70)
                        make.leading.equalTo(self.pdfContainer.snp.leading).offset(0)
                        make.trailing.equalTo(self.pdfContainer.snp.trailing).offset(0)
                    }
                    thumbnailView.snp.makeConstraints { (make) in
                        make.top.equalTo(pdfView.snp.bottom).offset(0)
                        make.bottom.equalTo(self.pdfContainer.snp.bottom).offset(0)
                        make.leading.equalTo(self.pdfContainer.snp.leading).offset(0)
                        make.trailing.equalTo(self.pdfContainer.snp.trailing).offset(0)
                    }
                }
                thumbnailView.pdfView = pdfView
                if let document = PDFDocument(url: url) {
                    pdfView.document = document
                }
            }
        }
    }
}
