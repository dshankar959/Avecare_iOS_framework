import Foundation
import UIKit
import CoreGraphics



protocol SettingsDataProvider: class {
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> SettingTableViewCellModel
    func setSelected(_ isSelected: Bool, at indexPath: IndexPath)
    func privacyPolicyForm() -> Form
    func termsAndConditionsForm() -> Form

}

protocol SettingsDataProviderDelegate: class {
    func didUpdateModel(at indexPath: IndexPath)
    func showPrivacyPolicy()
    func showTermsAndConditions()
//    func showRules()
}


class DefaultSettingDataProvider: SettingsDataProvider {

    private var lastSelectedIndexPath: IndexPath?

    weak var delegate: SettingsDataProviderDelegate? {
        didSet {
            let infoText = appSession.userProfile.email
            let version = appVersionAndBuildDateString()
            dataSource = [

                SettingTableViewCellModel(icon: R.image.scrollIcon(),
                                                          color: R.color.blueIcon(),
                                                          text: NSLocalizedString("settings_menutitle_terms_of_use_policy", comment: ""), isEnabled: true,
                                                          action: delegate?.showTermsAndConditions),

                SettingTableViewCellModel(icon: R.image.shieldIcon(),
                                          color: R.color.blueIcon(),
                                          text: NSLocalizedString("settings_menutitle_privacy_policy", comment: ""), isEnabled: true,
                                          action: delegate?.showPrivacyPolicy),

                SettingTableViewCellModel(icon: R.image.avatar_default(),
                                          color: R.color.blueIcon(),
                                          text: infoText, isEnabled: false,
                                          action: nil),

                SettingTableViewCellModel(icon: R.image.infoIcon(),
                                          color: UIColor.gray,
                text: version, isEnabled: false,
                action: nil)
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

    func privacyPolicyForm() -> Form {
        return Form(viewModels: [
            WebViewFormViewModel(urlString: "https://avecare.ca/privacy/")])
    }

    func termsAndConditionsForm() -> Form {
        return Form(viewModels: [
            WebViewFormViewModel(urlString: "https://avecare.ca/terms/")])
    }

}
