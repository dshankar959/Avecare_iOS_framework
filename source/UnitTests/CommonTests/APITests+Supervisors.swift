//
//  APITests+Supervisors.swift
//  parentTests
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

    func testSupervisorDetailsAPI() throws {
        // given
        let supervisorId = "test_supervisor_id"
        let expectation = self.expectation(description: "Supervisor Details")

        // when
        SupervisorsAPIService.getSupervisorDetails(for: supervisorId) { (result) in
            // then
            switch result {
            case .success(let supervisor):
                if supervisor.id == supervisorId {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong supervisor: \(supervisor.id)")
                }
            case .failure(let error):
                XCTFail("Failed to get supervisor details: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
