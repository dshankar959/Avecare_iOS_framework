//
//  APITests+Units.swift
//  educator
//
//  Created by stephen on 2020-10-13.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import XCTest
#if SUPERVISOR
@testable import educator
#elseif GUARDIAN
@testable import parent
#endif

extension APITests {

    func testUnitDetailsAPI() throws {
        // given
        let unitId = "test_unit_id"
        let expectation = self.expectation(description: "Unit Details")
        // when
        UnitsAPIService.getUnitDetails(unitId: unitId) { (result) in
            // then
            switch result {
            case .success(let unit):
                if unit.id == unitId, unit.name == "Test Class" {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong unit: \(unit.id)")
                }
            case .failure(let error):
                XCTFail("Failed to get unit details: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUnitSubjectsAPI() throws {
        // given
        let unitId = "test_unit_id"
        let expectation = self.expectation(description: "Unit Subjects")
        // when
        UnitsAPIService.getSubjects(unitId: unitId) { (result) in
            // then
            switch result {
            case .success(let subjects):
                if subjects.count == 2,
                    subjects.first?.id == "first_subject_id",
                    subjects.last?.id == "second_subject_id" {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong unit subjects: \(subjects)")
                }
            case .failure(let error):
                XCTFail("Failed to get unit subjects: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUnitSupervisorsAPI() throws {
        // given
        let unitId = "test_unit_id"
        let expectation = self.expectation(description: "Unit Supervisos")
        // when
        UnitsAPIService.getSupervisorAccounts(unitId: unitId) { (result) in
            // then
            switch result {
            case .success(let supervisorAccounts):
                if supervisorAccounts.count > 0 {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong unit supervisors:")
                }
            case .failure(let error):
                XCTFail("Failed to get unit supervisors: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
