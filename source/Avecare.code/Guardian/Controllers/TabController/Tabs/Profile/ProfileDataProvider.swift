//
//  ProfileDataProvider.swift
//  educator
//
//  Created by stephen on 2020-05-15.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import Foundation

protocol ProfileDataProvider: class {
    var numberOfSections: Int { get }
    func numberOfRows(for section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    //func details(at indexPath: IndexPath) -> StoriesDetails
}

class DefaultProfileDataProvider: ProfileDataProvider {

    private struct Section {
        let profileMenus: [ProfileMenuTableViewCellModel]
    }

    let subjects = DefaultSubjectListDataProvider()
    let educators = DefaultEducatorsDataProvider()

    private lazy var dataSource: [Section] = [
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "utensils", menuTitle: "Menu"),
            ProfileMenuTableViewCellModel(menuImage: "calendar", menuTitle: "Activity")
        ]),
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "", menuTitle: "About the Application")
        ]),
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "", menuTitle: "Log Out", disclosable: false)
        ])
    ]

    var numberOfSections: Int {
        return dataSource.count + 2
    }

    func numberOfRows(for section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        default:
            return dataSource[section - 2].profileMenus.count
        }
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        switch indexPath.section {
        case 0:
            return ProfileSubjectTableViewCellModel(dataProvider: subjects)
        case 1:
            return SupervisorFilterTableViewCellModel(dataProvider: educators)
        default:
            return dataSource[indexPath.section - 2].profileMenus[indexPath.row]
        }
    }
}
