import UIKit



class SettingsSideViewController: UIViewController {

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
    }

}


extension SettingsSideViewController {

    @IBAction func didTapSignOut(_ recognizer: UITapGestureRecognizer) {

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
