import Foundation
import UIKit
import WebKit
import SnapKit

struct WebViewFormViewModel: CellViewModel {
    typealias CellType = UIView

    let urlString: String
    var webView: WKWebView?

    func setup(cell: CellType) {
        let webView = WKWebView()
        cell.addSubview(webView)
        cell.backgroundColor = UIColor.white
        webView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset( UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 60))
        }
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
            webView.contentMode = .scaleToFill
        }
    }
}
