import Foundation
import UIKit
import SnapKit



class SupervisorTabBarButton: UIButton {

    weak var item: UITabBarItem?

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        let imageRect = super.imageRect(forContentRect: contentRect)

        return CGRect(x: 0, y: imageRect.maxY, width: contentRect.width, height: rect.height)
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)
        let titleRect = self.titleRect(forContentRect: contentRect)

        return CGRect(x: contentRect.width/2.0 - rect.width/2.0,
                      y: (contentRect.height - titleRect.height)/2.0 - rect.height/2.0,
                      width: rect.width, height: rect.height)
    }

    convenience init(item: UITabBarItem) {
        self.init(type: .custom)
        setImage(item.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        setTitle(item.title, for: .normal)

        self.item = item
        centerTitleLabel()
    }

    private func centerTitleLabel() {
        self.titleLabel?.textAlignment = .center
    }

}
