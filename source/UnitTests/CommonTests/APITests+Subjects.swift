//
//  APITests+Subjects.swift
//  Avecare
//
//  Created by stephen on 2020-10-21.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import XCTest
#if SUPERVISOR
@testable import educator
#elseif GUARDIAN
@testable import parent
#endif

extension APITests {

    func testPublishDailyLogAPI() throws {
        // given
        let subjectId = "sample_subject_id"
        let logFormId = "sample_log_form_id"
        let subject = RLMSubject(id: subjectId)
        let logForm = RLMLogForm(id: logFormId)
        logForm.subject = subject
        logForm.clientLastUpdated = Date()
        let request = LogFormAPIModel(form: logForm, storage: DocumentService())
        let expectation = self.expectation(description: "Publish Daily Log")
        // when
        SubjectsAPIService.publishDailyLog(log: request) { (result) in
            // then
            switch result {
            case .success(let logFormModel):
                if logFormModel.id == logFormId, logFormModel.subjectId == subjectId {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong log from: \(logFormModel)")
                }
            case .failure(let error):
                XCTFail("Failed to publish daily log: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testGetLogsAPI() throws {
        // given
        let subjectId = "sample_subject_id"
        let request = SubjectsAPIService.SubjectLogsRequest(id: subjectId)
        let expectation = self.expectation(description: "Published Daily Log")
        // when
        SubjectsAPIService.getLogs(request: request) { (result) in
            // then
            switch result {
            case .success(let logFormModels):
                if logFormModels.count == 1, logFormModels.first?.subjectId == subjectId {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong log forms: \(logFormModels)")
                }
            case.failure(let error):
                XCTFail("Failed to get daily logs: \(error)")
            }
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
