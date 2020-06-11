import UIKit



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
        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.register(nibModels: [SettingTableViewCellModel.self])

        configSignoutButton()
    }

    private func configSignoutButton() {
        signOutButton.nameText = NSLocalizedString("settings_menutitle_sign_out", comment: "")
        signOutButton.iconImage = R.image.signoutIcon()
        signOutButton.iconColor = R.color.redIcon()
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


extension SettingsSideViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        return tableView.dequeueReusableCell(withModel: model, for: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataProvider.model(for: indexPath).action?()
    }

}


extension SettingsSideViewController: SettingsDataProviderDelegate {

    func showAbout() {

    }

    func showPrivacyPolicy() {

    }

    func showRules() {

    }

}
