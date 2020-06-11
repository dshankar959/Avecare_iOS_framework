import Foundation
import UIKit
import SnapKit



private let tabBarHeight: CGFloat = 80

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


private protocol CustomTabBarViewDelegate: class {
    func tabBar(_ tabBar: CustomTabBarView, didClickItem button: SupervisorTabBarButton)
    var selectedTabBarItem: UITabBarItem? { get }
}


private class CustomTabBarView: UIView {

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
                maker.top.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-tabBarHeight)
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

class SupervisorTabBarController: UITabBarController {
    private lazy var customBar: CustomTabBarView = {
        return CustomTabBarView(delegate: self)
    }()

    var observation: NSKeyValueObservation?

    override var selectedIndex: Int {
        didSet {
            customBar.sync()
            selectedViewController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customBar.sync()
        selectedViewController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
    }

    func onLogout() {
        dismiss(animated: true, completion: nil)
    }

    deinit {
        observation?.invalidate()
        observation = nil
    }

    private func configureTabBar() {
        view.addSubview(customBar)
        tabBar.isHidden = true
        customBar.setItems(tabBar.items, animated: false)
        observation = observe(\.tabBar.items, options: .new) { [weak self] _, change in
            if let items = change.newValue {
                self?.customBar.setItems(items, animated: false)
            }
        }
    }

}


extension SupervisorTabBarController: CustomTabBarViewDelegate {

    fileprivate func tabBar(_ tabBar: CustomTabBarView, didClickItem button: SupervisorTabBarButton) {
        guard let item = button.item, let index = self.tabBar.items?.firstIndex(of: item),
              selectedIndex != index else {
            return
        }
        selectedIndex = index
    }

    fileprivate var selectedTabBarItem: UITabBarItem? {
        return tabBar.selectedItem
    }

}
