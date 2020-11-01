//
//  APITests+Guardians.swift
//  educator
//
//  Created by stephen on 2020-10-08.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import XCTest
#if SUPERVISOR
@testable import educator
#elseif GUARDIAN
@testable import parent
#endif

extension APITests {
    
    func testGuardianDetailsAPI() throws {
        // given
        let guardianId = "test_guardian_id"
        let expectation = self.expectation(description: "Guardian Details")
        // when
        GuardiansAPIService.getGuardianDetails(for: guardianId) { (result) in
            // then
            switch result {
            case .success(let guardian):
                if guardian.id == guardianId {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong guardian: \(guardian.id)")
                }
            case .failure(let error):
                XCTFail("Failed to get guardian details: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }

    func testGuardianFeedsAPI() throws {
        // given
        let guardianId = "test_guardian_id"
        let expectation = self.expectation(description: "Guardian Feeds")
        // when
        GuardiansAPIService.getGuardianFeed(for: guardianId) { (result) in
            // then
            switch result {
            case .success(let feeds):
                if feeds.count == 3 {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong feed count: \(feeds.count)")
                }
            case .failure(let error):
                XCTFail("Failed to get feeds: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }

    func testGuardianSubjectsAPI() throws {
        // given
        let guardianId = "test_guardian_id"
        let expectation = self.expectation(description: "Subjects")
        // when
        GuardiansAPIService.getSubjects(for: guardianId) { (result) in
            // then
            switch result {
            case .success(let subjects):
                if subjects.count == 2,
                    subjects.first?.id == "first_subject_id",
                    subjects.last?.id == "second_subject_id" {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong guardian subjects: \(subjects)")
                }
            case .failure(let error):
                XCTFail("Failed to get guardian subjects: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }
}
