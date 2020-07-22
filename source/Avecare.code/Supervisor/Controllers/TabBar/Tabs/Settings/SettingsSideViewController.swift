import UIKit
import CocoaLumberjack



class SettingsSideViewController: UIViewController, IndicatorProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signOutButton: DefaultCellView!

    lazy var dataProvider: SettingsDataProvider = {
        let provider = DefaultSettingDataProvider()
        provider.delegate = self
        return provider
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Force a test crash
//        fatalError()    // FIXME:  remove for release.

        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.register(nibModels: [SettingTableViewCellModel.self])

        if dataProvider.numberOfRows > 0 {
            dataProvider.setSelected(true, at: IndexPath(row: 0, section: 0))
        }

        configSignoutButton()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let detailsViewController = customSplitController?.rightViewController as? DetailsFormViewController {
            detailsViewController.updateSyncButton()
        }
    }

    private func configSignoutButton() {
        signOutButton.nameText = NSLocalizedString("settings_menutitle_sign_out", comment: "")
        signOutButton.iconImage = R.image.signoutIcon()
        signOutButton.iconColor = R.color.redIcon()
    }

}


extension SettingsSideViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        let cell = tableView.dequeueReusableCell(withModel: model, for: indexPath)

        if !model.isEnabled {
          cell.selectionStyle = .none
          cell.isUserInteractionEnabled = false
        } else {
          cell.selectionStyle = .default
          cell.isUserInteractionEnabled = true
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataProvider.setSelected(true, at: indexPath)
    }

}


extension SettingsSideViewController: SettingsDataProviderDelegate {

    func didUpdateModel(at indexPath: IndexPath) {
        let model = dataProvider.model(for: indexPath)

        if let cell = tableView.cellForRow(at: indexPath) {
            model.setup(cell: cell)
        }
    }

    func showPrivacyPolicy() {
        DDLogVerbose("")

        if let detailsViewController = customSplitController?.rightViewController as? DetailsFormViewController {
            detailsViewController.updateSyncButton()
            let form = dataProvider.privacyPolicyForm()
            detailsViewController.detailsView.setFormViews(form.viewModels)
            detailsViewController.detailsView.allignStackViewForWebView()

        }
    }

    func showTermsAndConditions() {
        DDLogVerbose("")

        if let detailsViewController = customSplitController?.rightViewController as? DetailsFormViewController {
            detailsViewController.updateSyncButton()
            let form = dataProvider.termsAndConditionsForm()
            detailsViewController.detailsView.setFormViews(form.viewModels)
            detailsViewController.detailsView.allignStackViewForWebView()

        }
    }

}


extension SettingsSideViewController {

    @IBAction func didTapSignOut(_ recognizer: UITapGestureRecognizer) {
        // Sign-out
        UserAuthenticateService.shared.signOut { [weak self] error in
            if let error = error {
                self?.showErrorAlert(error)
            } else {
                if let tabBarController = self?.tabBarController as? SupervisorTabBarController {
                    tabBarController.onLogout()
                }
            }
        }
    }

}
