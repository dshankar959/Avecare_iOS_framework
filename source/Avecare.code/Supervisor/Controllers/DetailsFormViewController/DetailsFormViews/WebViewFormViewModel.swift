import UIKit
import WebKit
import SnapKit



struct WebViewFormViewModel: CellViewModel {

    typealias CellType = UIView

    let urlString: String
    var webView = WKWebView()
    let tView = UITextView(frame: CGRect(x: 0, y: 0, width: 500, height: 100))


    func setup(cell: CellType) {
    }

    func buildView() -> UIView {
        let view = UIView()

        view.setSubviewForAutoLayout(webView)

        tView.isUserInteractionEnabled = false
        tView.textAlignment = .left
        tView.font = UIFont.systemFont(ofSize: 18)
        tView.text = NSLocalizedString("settings_no_internet_message", comment: "")
        view.setSubviewForAutoLayout(tView)

        tView.snp.makeConstraints { maker in
            maker.width.equalTo(400)
            maker.height.equalTo(200)
            maker.top.equalTo(40)
            maker.left.equalTo(-15)
        }

        view.backgroundColor = UIColor.white

        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: -40, left: -38, bottom: -80, right: -40))
        }

        if isDataConnection {
            tView.isHidden = true
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                webView.load(request)
                webView.contentMode = .scaleToFill
            }
        } else {
            tView.isHidden = false
        }

        return view
    }

}