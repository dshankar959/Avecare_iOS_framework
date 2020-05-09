import Foundation

protocol SettingsDataProvider: class {
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> SettingTableViewCellModel
}

protocol SettingsDataProviderDelegate: class {
    func showAbout()
    func showPrivacyPolicy()
    func showRules()
}

class DefaultSettingDataProvider: SettingsDataProvider {
    weak var delegate: SettingsDataProviderDelegate? {
        didSet {
            dataSource = [
                SettingTableViewCellModel(icon: R.image.infoIcon(), color: R.color.blueIcon(), text: "About the App", action: delegate?.showAbout),
//                SettingTableViewCellModel(icon: R.image.shieldIcon(), color: R.color.blueIcon(), text: "Privacy Policy", action: delegate?.showPrivacyPolicy),
//                SettingTableViewCellModel(icon: R.image.scrollIcon(), color: R.color.blueIcon(), text: "Classroom Rules", action: delegate?.showRules)
            ]
        }
    }

    var dataSource = [SettingTableViewCellModel]()

    var numberOfRows: Int {
        dataSource.count
    }

    func model(for indexPath: IndexPath) -> SettingTableViewCellModel {
        return dataSource[indexPath.row]
    }
}
