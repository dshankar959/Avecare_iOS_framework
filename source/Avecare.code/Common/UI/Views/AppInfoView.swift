import UIKit
import CocoaLumberjack
import SnapKit



class AppInfoView: UIView {

    let appInfoLabel: UILabel = UILabel()


    override init(frame: CGRect) {
        super.init(frame: frame)

        appInfoLabel.numberOfLines = 0
        appInfoLabel.textAlignment = .center

        var infoText = appSession.userProfile.email
        infoText += "\n\(appVersionAndBuildDateString())"

        let fontSize: CGFloat = hardwareDevice.isPad ? 16.0 : 14.0
        let attrInfoText = NSAttributedString(string: infoText,
                                              attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
                                              .withLineSpacing(7, centered: true)
        appInfoLabel.attributedText = attrInfoText
        appInfoLabel.textColor = .gray

        self.setSubviewForAutoLayout(appInfoLabel)
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        appInfoLabel.snp.remakeConstraints { [unowned self] (make) -> Void in
            make.width.height.equalToSuperview()
            make.centerX.equalTo(self)
        }
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DDLogError("has not been implemented")
        fatalError("init(coder:) has not been implemented")
    }


    deinit {
        DDLogWarn("\(self)")
    }

}
