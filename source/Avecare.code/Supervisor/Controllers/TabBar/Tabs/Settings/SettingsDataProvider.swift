import Foundation
import UIKit
import CoreGraphics



protocol SettingsDataProvider: class {
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> SettingTableViewCellModel
    func setSelected(_ isSelected: Bool, at indexPath: IndexPath)
    func aboutForm() -> Form
    func privacyPolicyForm() -> Form
}

protocol SettingsDataProviderDelegate: class {
    func didUpdateModel(at indexPath: IndexPath)
    func showAbout()
    func showPrivacyPolicy()
//    func showRules()
}


class DefaultSettingDataProvider: SettingsDataProvider {

    private var lastSelectedIndexPath: IndexPath?

    weak var delegate: SettingsDataProviderDelegate? {
        didSet {
            dataSource = [
                SettingTableViewCellModel(icon: R.image.infoIcon(),
                                          color: R.color.blueIcon(),
                                          text: NSLocalizedString("settings_menutitle_about_the_app", comment: ""),
                                          action: delegate?.showAbout),

                SettingTableViewCellModel(icon: R.image.shieldIcon(),
                                          color: R.color.blueIcon(),
                                          text: NSLocalizedString("settings_menutitle_privacy_policy", comment: ""),
                                          action: delegate?.showPrivacyPolicy)
/*
                SettingTableViewCellModel(icon: R.image.scrollIcon(),
                                          color: R.color.blueIcon(),
                                          text: NSLocalizedString("settings_menutitle_classroom_rule", comment: ""),
                                          action: delegate?.showRules)
*/
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

    func setSelected(_ isSelected: Bool, at indexPath: IndexPath) {
        if isSelected {
            if let last = lastSelectedIndexPath {
                if last != indexPath {
                    // deselect
                    dataSource[last.row].isSelected = false
                    delegate?.didUpdateModel(at: last)
                } else {
                    // already selected
                    return
                }
            }
            dataSource[indexPath.row].isSelected = isSelected
            lastSelectedIndexPath = indexPath
            delegate?.didUpdateModel(at: indexPath)
        } else {
            guard let last = lastSelectedIndexPath, last == indexPath else {
                return
            }
            dataSource[last.row].isSelected = false
            delegate?.didUpdateModel(at: last)
        }

        model(for: indexPath).action?()
    }


    func aboutForm() -> Form {
        let fontSize: CGFloat = hardwareDevice.isPad ? 16.0 : 14.0

        var infoText = appSession.userProfile.email
        infoText += "\n\n\(appVersionAndBuildDateString())"

        return Form(viewModels: [
            LabelFormViewModel(font: UIFont.systemFont(ofSize: fontSize), color: .black, text: infoText)])
    }


    func privacyPolicyForm() -> Form {
        let fontSize: CGFloat = hardwareDevice.isPad ? 16.0 : 14.0

        return Form(viewModels: [
            LabelFormViewModel(font: UIFont.systemFont(ofSize: fontSize), color: .black, text: "")])
    }

}
