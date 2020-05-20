import UIKit
import CocoaLumberjack

protocol SubjectSelectionProtocol: class {
    var subject: RLMSubject? { get set }
}


class GuardianTabBarController: UITabBarController, SubjectSelectionProtocol {
    // shared subject selection
    var subject: RLMSubject?

    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("")

    }


}
