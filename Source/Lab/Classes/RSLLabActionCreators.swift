//
//  RSLLabActionCreators.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import UIKit
import ReSwift

public class RSLLabActionCreators: NSObject {
    
    public static func startSession(
        sessionId: String,
        taskBuilderManager: RSAFTaskBuilderManager,
        resultsProcessorManager: RSAFResultsProcessorManager
        ) -> Action {
        
        return StartSession(
            sessionId: sessionId,
            taskBuilderManager: taskBuilderManager,
            resultsProcessorManager: resultsProcessorManager
        )
        
    }
    
    public static func endCurrentSession() -> Action {
        return EndSession()
    }
    
//    public static func setSessionId(sessionId: String?) -> Action {
//        return SetSessionId(sessionId: sessionId)
//    }
//    
    public static func markResearcherDemographicsCompleted(completed: Bool) -> Action {
        return MarkResearcherDemographicsCompleted(completed: completed)
    }
    
//    public static func setSessionTaskBuilderManager(taskBuilderManager: RSAFTaskBuilderManager) -> Action {
//        return SetSessionTaskBuilderManager(taskBuilderManager: taskBuilderManager)
//    }
//    
//    public static func setSessionResultsProcessorManager(resultsProcessorManager: RSAFResultsProcessorManager) -> Action {
//        return SetSessionResultsProcessorManager(resultsProcessorManager: resultsProcessorManager)
//    }

    public static func setValueInSessionStorage(key: String, value: NSObject?) -> Action {
        return SetValueInSessionStorage(key: key, value: value)
    }
    
}
