import UIKit
import CocoaLumberjack



class GuardianTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("")

        // disable profile view temporarily.
        //self.viewControllers?.remove(at: 3)

    }


}
