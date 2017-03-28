//
//  RSLLabActions.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import ReSwift

struct MarkResearcherDemographicsCompleted: Action {
    let completed: Bool
}

struct SetSessionId: Action {
    let sessionId: String?
}

struct SetValueInSessionStorage: Action {
    let key: String
    let value: NSObject?
}
