import Foundation
import UIKit
import SnapKit

extension UIViewController {
    var customSplitController: CustomSplitViewController? {
        return parent as? CustomSplitViewController
    }
}

class CustomSplitViewController: UIViewController {
    @IBInspectable var leftControllerStoryboardName: String?
    @IBInspectable var leftControllerIdentifier: String?
    @IBInspectable var rightControllerStoryboardName: String?
    @IBInspectable var rightControllerIdentifier: String?

    private(set) var leftViewController: UIViewController?
    private(set) var rightViewController: UIViewController?

    @IBOutlet weak var leftContainerView: UIView!
    @IBOutlet weak var rightContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // details
        if let name = rightControllerStoryboardName, let identifier = rightControllerIdentifier {
            let storyboard = UIStoryboard(name: name, bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: identifier)
            setRightViewController(controller)
        }

        // master
        if let name = leftControllerStoryboardName, let identifier = leftControllerIdentifier {
            let storyboard = UIStoryboard(name: name, bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: identifier)
            setLeftViewController(controller)
        }
    }

    func setLeftViewController(_ controller: UIViewController?) {
        if let controller = leftViewController {
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }

        if let controller = controller {
            controller.willMove(toParent: self)
            addChild(controller)
            leftContainerView.addSubview(controller.view)
            controller.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            controller.didMove(toParent: self)
        }

        leftViewController = controller
    }

    func setRightViewController(_ controller: UIViewController?) {
        if let controller = rightViewController {
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }

        if let controller = controller {
            controller.willMove(toParent: self)
            addChild(controller)
            rightContainerView.addSubview(controller.view)
            controller.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            controller.didMove(toParent: self)
        }

        rightViewController = controller
    }
}
