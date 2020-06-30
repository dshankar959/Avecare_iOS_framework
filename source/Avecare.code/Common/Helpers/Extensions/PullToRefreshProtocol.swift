import UIKit
import CocoaLumberjack
import SwiftPullToRefresh



protocol PullToRefreshProtocol: class {
    var pullToRefreshHeaderView: PullToRefreshHeaderView! { get set }

    func setupPullToRefresh(for tableView: UITableView, action: @escaping () -> Void)
}


extension PullToRefreshProtocol {

    func setupPullToRefresh(for tableView: UITableView, action: @escaping () -> Void) {
        pullToRefreshHeaderView = PullToRefreshHeaderView(height: 120, action: action, cancelAction: {})
        tableView.spr_setCustomHeader(pullToRefreshHeaderView)
    }


    func endPullToRefresh(for tableView: UITableView) {
        tableView.spr_endRefreshing()
    }


    func triggerPullToRefresh(for tableView: UITableView) {
        tableView.spr_beginRefreshing()
    }

}



final class PullToRefreshHeaderView: RefreshView {
    private let indicator = UIActivityIndicatorView(style: .gray)
    private let isHeader: Bool

    private var loadingText = "Syncing/refreshing ..."
    private var pullingText = "Pull to refresh"
    private var releaseText = "Release to refresh"

    private lazy var arrowLayer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 0, y: -8))
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 5.66, y: 2.34))
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: -5.66, y: 2.34))

        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.red.withAlphaComponent(0.8).cgColor
        layer.lineWidth = 2
        layer.lineCap = .round
        return layer
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.red.withAlphaComponent(0.8)
        return label
    }()
/*
    private lazy var cancelButton: UIButton = { [unowned self] in
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 30))

        let buttonImage = UIImage.fontAwesomeIcon(name: .timesCircle, style: .light, textColor: .red, size: CGSize(width: 26, height: 26))
        button.setImage(buttonImage, for: UIControl.State())

        button.setTitleColor(.red, for: UIControl.State())
        button.setTitleColor(.red, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .center
        button.backgroundColor = UIColor(hex: "ebebeb")
        button.set(cornerRadius: 5)

        button.setTitle("Cancel", for: UIControl.State())
        button.addTarget(self, action: #selector(cancelButtonDidPress), for: .touchUpInside)

        return button
        }()
*/
    let cancelAction: () -> Void


    // MARK: -
    init(isHeader: Bool = true, height: CGFloat, action: @escaping () -> Void, cancelAction: @escaping () -> Void) {

        self.isHeader = isHeader
        self.cancelAction = cancelAction
        super.init(style: isHeader ? .header : .footer, height: height, action: action)

        indicator.color = .red

        layer.addSublayer(arrowLayer)
        addSubview(indicator)
        addSubview(label)
//        addSubview(cancelButton)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        let center = CGPoint(x: bounds.midX, y: bounds.midY-18)

        arrowLayer.position = center.move(x: -label.bounds.midX - 4)
        indicator.center = center.move(x: -label.bounds.midX - 4)
        label.center = center.move(x: indicator.bounds.midX + 4)

//        cancelButton.center = CGPoint(x: bounds.midX, y: bounds.midY+18)
    }


    override func didUpdateState(_ isRefreshing: Bool) {
        arrowLayer.isHidden = isRefreshing
        isRefreshing ? indicator.startAnimating() : indicator.stopAnimating()
        label.text = isRefreshing ? loadingText : pullingText
        label.sizeToFit()
    }


    override func didUpdateProgress(_ progress: CGFloat) {
        let rotation = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        if isHeader {
            arrowLayer.transform = progress == 1 ? rotation : CATransform3DIdentity
        } else {
            arrowLayer.transform = progress == 1 ? CATransform3DIdentity : rotation
        }

        label.text = progress == 1 ? releaseText : pullingText
        label.sizeToFit()
    }


    func updateLabelText(with newText: String) {
        label.text = newText
        label.sizeToFit()
    }


    @objc func cancelButtonDidPress() {
        DDLogInfo("")

        self.cancelAction()
    }


}
