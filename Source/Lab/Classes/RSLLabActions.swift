//
//  RSLLabActions.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import ReSwift
import ResearchSuiteResultsProcessor
import ResearchSuiteTaskBuilder

struct MarkResearcherDemographicsCompleted: Action {
    let completed: Bool
}

struct StartSession: Action {
    let sessionId: String
    let sessionLabel: String?
    let taskBuilder: RSTBTaskBuilder
    let resultsProcessor: RSRPResultsProcessor
}

struct ResumeSession: Action {
    let taskBuilder: RSTBTaskBuilder
    let resultsProcessor: RSRPResultsProcessor
}

//struct SetSessionId: Action {
//    let sessionId: String?
//}

struct SetValueInSessionStorage: Action {
    let key: String
    let value: NSObject?
}

//struct SetSessionTaskBuilderManager: Action {
//    let taskBuilderManager: RSAFTaskBuilderManager
//}
//
//struct SetSessionResultsProcessorManager: Action {
//    let resultsProcessorManager: RSAFResultsProcessorManager
//}

struct EndSession: Action {}
