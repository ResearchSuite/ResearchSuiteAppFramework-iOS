//
//  RSLLabStateSelectors.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchSuiteTaskBuilder

public class RSLLabSelectors: NSObject {

    public static func isResearcherDemographicsCompleted(_ state: RSLLabState) -> Bool {
        return state.researcherDemographicsCompleted
    }
    
    public static func getSessionId(_ state: RSLLabState) -> String? {
        return state.sessionId
    }
    
    public static func getSessionLabel(_ state: RSLLabState) -> String? {
        return state.sessionLabel
    }
    
    public static func getSessionStorage(_ state: RSLLabState) -> [String : NSObject] {
        return state.sessionStorage
    }
    
    public static func getValueInSessionStorage(_ state: RSLLabState) -> (String) -> NSSecureCoding? {
        return { key in
            return state.sessionStorage[key] as? NSSecureCoding
        }
    }

    public static func getSessionTaskBuilder(_ state: RSLLabState) -> RSTBTaskBuilder? {
        return state.sessionTaskBuilder
    }
    
    public static func getSessionResultsProcessor(_ state: RSLLabState) -> RSRPResultsProcessor? {
        return state.sessionResultsProcessor
    }
    
}
