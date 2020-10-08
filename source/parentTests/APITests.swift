//
//  APITests.swift
//  parentTests
//
//  Created by stephen on 2020-10-07.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import XCTest
@testable import parent

class APITests: XCTestCase {

    func testUserAuthenticationAPI() throws {
        // given
        let userCredentials = UserCredentials(email: "test@avecare.ca", password: "1234")
        let expectation = self.expectation(description: "User Authentication")

        // when
        UserAPIService.authenticateUserWith(userCreds: userCredentials) { (result) in
            // then
            switch result {
            case .success(let token):
                if (token.accountType == "guardian" &&
                    token.accountTypeId == "sample_id" &&
                    token.accessToken == "sample_token") {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong value for token")
                }
            case .failure(let error):
                XCTFail("Failed to authenticate: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
