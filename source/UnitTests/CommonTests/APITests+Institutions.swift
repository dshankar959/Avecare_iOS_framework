//
//  APITests+Institutions.swift
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

    func testInstitutionDetailsAPI() throws {
        // given
        let institutionId = "test_institution_id"
        let expectation = self.expectation(description: "Institution Details")
        // when
        InstitutionsAPIService.getInstitutionDetails(id: institutionId) { (result) in
            // then
            switch result {
            case .success(let institution):
                if institution.id == institutionId, institution.name == "Test School" {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong institution: \(institution.id)")
                }
            case .failure(let error):
                XCTFail("Failed to get institution details: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }
}
