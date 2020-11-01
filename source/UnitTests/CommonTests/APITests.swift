//
//  APITests.swift
//  parentTests
//
//  Created by stephen on 2020-10-07.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import XCTest
#if SUPERVISOR
@testable import educator
#elseif GUARDIAN
@testable import parent
#endif

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
                    XCTFail("Wrong value for token: \(token.accessToken)")
                }
            case .failure(let error):
                XCTFail("Failed to authenticate: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }

    func testRequestOTPAPI() throws {
        // given
        let userEmail = "test@avecare.ca"
        let expectation = self.expectation(description: "Request OTP")

        // when
        UserAPIService.requestOTP(email: userEmail) { (result) in
            // then
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to request OTP: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }

    func testLogoutAPI() throws {
        // given
        let expectation = self.expectation(description: "Logout")

        // when
        UserAPIService.logout { (result) in
            // then
            switch result {
            case .success(let statusCode):
                if (statusCode == 200) {
                    expectation.fulfill()
                } else {
                    XCTFail("Status code is not 200: \(statusCode)")
                }
            case .failure(let error):
                XCTFail("Failed to logout: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }
}
