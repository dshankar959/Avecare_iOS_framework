//
//  AboutDetailsViewController.swift
//  parent
//
//  Created by stephen on 2020-05-19.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit

enum AboutDetails: String {
    case termsAndConditions = "Terms & Conditions"
    case privacyPolicy = "Privacy Policy"
    case aboutThisApp = "About This App"
}

class AboutDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    var aboutDetails: AboutDetails = .termsAndConditions

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = aboutDetails.rawValue

        switch aboutDetails {
        case .aboutThisApp:
            contentLabel.text = "Version " + Bundle.main.versionNumber
        default:
            // swiftlint:disable line_length
            contentLabel.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
            // swiftlint:enable line_length
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
