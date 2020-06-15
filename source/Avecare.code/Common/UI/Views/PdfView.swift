import Foundation
import UIKit
import SnapKit
import PDFKit

class PdfView: UIView {

    init() {
        super.init(frame: CGRect.zero)
    }

    func loadPDFat(url: URL) {

        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pdfView)
        pdfView.autoScales = true
        pdfView.backgroundColor =  UIColor.white
        pdfView.autoScales = true

        let thumbnailView = PDFThumbnailView()
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(thumbnailView)

        thumbnailView.backgroundColor = UIKit.UIColor(resource: R.color.background, compatibleWith: nil) ?? UIColor.white

        // check if ipad or iphone
        if hardwareDevice.isPad {
            thumbnailView.thumbnailSize = CGSize(width: 70, height: 70)
            thumbnailView.layoutMode = .vertical
            pdfView.snp.makeConstraints { (make) in
                make.top.equalTo(self.snp.top).offset(0)
                make.bottom.equalTo(self.snp.bottom).offset(0)
                make.leading.equalTo(self.snp.leading).offset(90)
                make.trailing.equalTo(self.snp.trailing).offset(0)
            }
            thumbnailView.snp.makeConstraints { (make) in
                make.top.equalTo(self.snp.top).offset(0)
                make.bottom.equalTo(self.snp.bottom).offset(0)
                make.leading.equalTo(self.snp.leading).offset(0)
                make.trailing.equalTo(pdfView.snp.leading).offset(0)
            }
        } else {
            thumbnailView.thumbnailSize = CGSize(width: 40, height: 40)
            thumbnailView.layoutMode = .horizontal
            pdfView.snp.makeConstraints { (make) in
                make.top.equalTo(self.snp.top).offset(0)
                make.bottom.equalTo(self.snp.bottom).offset(-70)
                make.leading.equalTo(self.snp.leading).offset(0)
                make.trailing.equalTo(self.snp.trailing).offset(0)
            }
            thumbnailView.snp.makeConstraints { (make) in
                make.top.equalTo(pdfView.snp.bottom).offset(0)
                make.bottom.equalTo(self.snp.bottom).offset(0)
                make.leading.equalTo(self.snp.leading).offset(0)
                make.trailing.equalTo(self.snp.trailing).offset(0)
            }
        }

        thumbnailView.pdfView = pdfView

        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("NSCoding not supported")
    }
}
