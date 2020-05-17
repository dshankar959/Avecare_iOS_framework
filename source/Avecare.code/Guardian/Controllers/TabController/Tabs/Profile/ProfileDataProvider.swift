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

    let subjects = DefaultSubjectsDataProvider()
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

protocol SubjectsDataProvider: class {
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> ProfileSubjectImageCollectionViewCellModel
}

class DefaultSubjectsDataProvider: SubjectsDataProvider {
    var dataSource: [ProfileSubjectImageCollectionViewCellModel] = [
        ProfileSubjectImageCollectionViewCellModel(avatarImage: R.image.subject1(),
                                                   fullName: "Liam Smith",
                                                   dobString: "2010/05/05"),
        ProfileSubjectImageCollectionViewCellModel(avatarImage: R.image.subject2(),
                                                   fullName: "William Johnes",
                                                   dobString: "2012/06/11"),
        ProfileSubjectImageCollectionViewCellModel(avatarImage: R.image.subject3(),
                                                   fullName: "Benjamin Hobbse",
                                                   dobString: "2013/10/25"),
        ProfileSubjectImageCollectionViewCellModel(avatarImage: R.image.subject4(),
                                                   fullName: "Elijah Robson",
                                                   dobString: "2011/03/15"),
        ProfileSubjectImageCollectionViewCellModel(avatarImage: R.image.subject5(),
                                                   fullName: "Brandon Fraser",
                                                   dobString: "2014/01/05")
    ]

    var numberOfRows: Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> ProfileSubjectImageCollectionViewCellModel {
        return dataSource[indexPath.row]
    }
}
