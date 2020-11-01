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
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
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
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
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
                if supervisorAccounts.count == 2,
                   supervisorAccounts.first?.supervisorId == "first_supervisor_id", supervisorAccounts.last?.supervisorId == "second_supervisor_id" {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong unit supervisors:\(supervisorAccounts)")
                }
            case .failure(let error):
                XCTFail("Failed to get unit supervisors: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }

    func testUnitPublishStoryAPI() throws {
        // given
        let unitId = "test_unit_id"
        let story = RLMStory()
        let model = PublishStoryRequestModel(unitId: unitId, story: story, storage: DocumentService())
        let expectation = self.expectation(description: "Unit Publish Story")
        // when
        UnitsAPIService.publishStory(model) { (result) in
            // then
            switch result {
            case .success(let story):
                if story.title == "Test Story" {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong published story: \(story)")
                }
            case .failure(let error):
                XCTFail("Failed to publish story: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }

    func testUnitPublishedStoriesAPI() throws {
        // given
        let unitId = "test_unit_id"
        let expectation = self.expectation(description: "Unit Published Stories")
        // when
        UnitsAPIService.getPublishedStories(unitId: unitId) { (result) in
            // then
            switch result {
            case .success(let stories):
                if stories.count == 2,
                   stories.first?.title == "First Story",
                   stories.last?.title == "Second Story" {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong published stories: \(stories)")
                }
            case .failure(let error):
                XCTFail("Failed to get unit published stories: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }

    func testUintPublishedDailyTaskFormsAPI() throws {
        // given
        let unitId = "test_unit_id"
        let request = UnitsAPIService.DailyTaskFormsRequest(unitId: unitId)
        let expectation = self.expectation(description: "Unit Published Daily Task Forms")
        // when
        UnitsAPIService.getPublishedDailyTaskForms(request: request) { (result) in
            // then
            switch result {
            case .success(let dailyTaskForms):
                if dailyTaskForms.count == 1,
                   dailyTaskForms.first?.id == "sample_daily_task_form_id",
                   dailyTaskForms.first?.tasks.count == 2 {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong published daily task forms: \(dailyTaskForms)")
                }
            case .failure(let error):
                XCTFail("Failed to get unit published daily task forms: \(error)")
            }
        }
        self.waitForExpectations(timeout: appSettings.expectationsTimeout, handler: nil)
    }
}
