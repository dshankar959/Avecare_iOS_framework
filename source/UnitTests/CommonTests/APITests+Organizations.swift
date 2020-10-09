//
//  APITests+Organizations.swift
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

    func testOrganizationDetailsAPI() throws {
        // given
        let organizationId = "test_organization_id"
        let expectation = self.expectation(description: "Organization Details")
        // when
        OrganizationsAPIService.getOrganizationDetails(id: organizationId) { (result) in
            // then
            switch result {
            case .success(let organization):
                if organization.id == organizationId {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong organization: \(organization.id)")
                }
            case .failure(let error):
                XCTFail("Failed to get organization details: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testOrganizationLogTemplatesAPI() throws {
        // given
        let organizationId = "test_organization_id"
        let expectation = self.expectation(description: "Organization Details")
        // when
        OrganizationsAPIService.getOrganizationLogTemplates(id: organizationId) { (result) in
            // then
            switch result {
            case .success(let templates):
                if templates.count > 0,
                    templates.first?.organization == organizationId {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong templates: \(String(describing: templates.first?.organization))")
                }
            case .failure(let error):
                XCTFail("Failed to get organization templates: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testOrganizationAvailableDailyTasksAPI() throws {
        // given
        let organizationId = "test_organization_id"
        let expectation = self.expectation(description: "Organization Available Daily Tasks")
        // when
        OrganizationsAPIService.getAvailableDailyTasks(for: organizationId) { (result) in
            // then
            switch result {
            case .success(let tasks):
                if (tasks.count == 1) {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong tasks")
                }
            case .failure(let error):
                XCTFail("Failed to get organization daily tasks: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testOrganizationAvailableActivitiesAPI() throws {
        // given
        let organizationId = "test_organization_id"
        let expectation = self.expectation(description: "Organization Available Activities")
        // when
        OrganizationsAPIService.getAvailableActivities(for: organizationId) { (result) in
            // then
            switch result {
            case .success(let activities):
                if (activities.count == 1) {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong activities")
                }
            case .failure(let error):
                XCTFail("Failed to get organization activitis: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testOrganizationAvailableInjuriesAPI() throws {
        // given
        let organizationId = "test_organization_id"
        let expectation = self.expectation(description: "Organization Available Injuries")
        // when
        OrganizationsAPIService.getAvailableInjuries(for: organizationId) { (result) in
            // then
            switch result {
            case .success(let injuries):
                if (injuries.count == 1) {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong injuries")
                }
            case .failure(let error):
                XCTFail("Failed to get organization injuries: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testOrganizationAvailableReminderssAPI() throws {
        // given
        let organizationId = "test_organization_id"
        let expectation = self.expectation(description: "Organization Available Reminders")
        // when
        OrganizationsAPIService.getAvailableReminders(for: organizationId) { (result) in
            // then
            switch result {
            case .success(let reminders):
                if (reminders.count == 1) {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong reminders")
                }
            case .failure(let error):
                XCTFail("Failed to get organization reminders: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
