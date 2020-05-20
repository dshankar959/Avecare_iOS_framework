//
//  EducatorDetailsDataProvider.swift
//  parent
//
//  Created by stephen on 2020-05-20.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit

protocol EducatorDetailsDataProvider: class {
    var numberOfSections: Int { get }
    func numberOfRows(section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    func addEducatorSummary(model: EducatorSummaryTableViewCellModel)
}

class DefaultEducatorDetailsDataProvider: EducatorDetailsDataProvider {
    private struct Section {
        let records: [AnyCellViewModel]
    }

    private var dataSource: [Section] = [
        Section(records: [
            LogsNoteTableViewCellModel(icon: R.image.certificationIcon(), iconColor: R.color.blueIcon(),
            title: "Special Education", text: "University of Sask. - 2018"),
            LogsNoteTableViewCellModel(icon: R.image.degreeIcon(), iconColor: R.color.blueIcon(),
            title: "BEd - Bachelors of Education", text: "York University - 2012")
        ])
    ]

    var numberOfSections: Int {
        return dataSource.count
    }

    func numberOfRows(section: Int) -> Int {
        return dataSource[section].records.count
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        return dataSource[indexPath.section].records[indexPath.row]
    }

    func addEducatorSummary(model: EducatorSummaryTableViewCellModel) {
        dataSource.insert(Section(records: [
            model
        ]), at: 0)
    }
}
