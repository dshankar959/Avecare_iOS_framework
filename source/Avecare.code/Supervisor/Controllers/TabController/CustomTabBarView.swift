import Foundation
import UIKit
import SnapKit



protocol CustomTabBarViewDelegate: class {
    func tabBar(_ tabBar: CustomTabBarView, didClickItem button: SupervisorTabBarButton)
    var selectedTabBarItem: UITabBarItem? { get }
}


class CustomTabBarView: UIView {

    var buttons = [SupervisorTabBarButton]()
    weak var delegate: CustomTabBarViewDelegate?

    convenience init(delegate: CustomTabBarViewDelegate) {
        self.init()
        backgroundColor = .white
        self.delegate = delegate
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            snp.makeConstraints { maker in
                maker.leading.trailing.bottom.equalToSuperview()
                maker.top.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-TabBarConfig.tabBarHeight)
            }
        }
    }

    func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        subviews.forEach({ $0.removeFromSuperview() })
        guard let items = items else {
            return
        }
        buttons = items.map({ SupervisorTabBarButton(item: $0) })
        guard let first = buttons.first, let last = buttons.last else {
            return
        }

        let leftSpacer = UIView()
        let rightSpacer = UIView()

        addSubview(leftSpacer)
        addSubview(rightSpacer)

        leftSpacer.snp.makeConstraints { maker in
            maker.width.equalToSuperview().multipliedBy(0.175)
            maker.leading.top.bottom.equalToSuperview()
        }
        rightSpacer.snp.makeConstraints { maker in
            maker.width.equalToSuperview().multipliedBy(0.175)
            maker.top.bottom.trailing.equalToSuperview()
        }

        buttons.forEach({ button in
            button.addTarget(self, action: #selector(didClickButtonItem(_:)), for: .touchUpInside)
            addSubview(button)
            button.snp.makeConstraints { maker in
                maker.top.equalToSuperview()
                maker.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            }
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(R.color.darkText(), for: .normal)
        })

        first.snp.makeConstraints {
            $0.left.equalTo(leftSpacer.snp.right)
        }
        last.snp.makeConstraints {
            $0.right.equalTo(rightSpacer.snp.left)
        }

        if buttons.count > 1 {
            for i in 1..<buttons.count {
                let button1 = buttons[i - 1]
                let button2 = buttons[i]
                button2.snp.makeConstraints { maker in
                    maker.width.equalTo(button1.snp.width)
                    maker.left.equalTo(button1.snp.right)
                }

                let separator =  UIView()
                addSubview(separator)
                separator.backgroundColor = R.color.lightText()
                separator.snp.makeConstraints { maker in
                    maker.width.equalTo(0.5)
                    maker.leading.equalTo(button1.snp.trailing)
                    maker.centerY.equalTo(button1)
                    maker.height.equalToSuperview().multipliedBy(0.5)
                }
            }
        }
    }

    @objc func didClickButtonItem(_ button: SupervisorTabBarButton) {
        delegate?.tabBar(self, didClickItem: button)
    }

    func sync() {
        buttons.forEach({ $0.isSelected = false; $0.tintColor = R.color.darkText() })
        guard let item = delegate?.selectedTabBarItem, let index = buttons.firstIndex(where: {$0.item == item}) else { return }
        buttons[index].isSelected = true
        buttons[index].tintColor = R.color.main()
    }
}
