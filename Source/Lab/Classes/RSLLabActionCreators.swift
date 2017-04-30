//
//  RSLLabActionCreators.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import UIKit
import ReSwift
import ResearchSuiteResultsProcessor
import ResearchSuiteTaskBuilder

public class RSLLabActionCreators: NSObject {
    
    public static func startSession(
        sessionId: String,
        sessionLabel: String?,
        taskBuilder: RSTBTaskBuilder,
        resultsProcessor: RSRPResultsProcessor
        ) -> Dispatchable<RSAFCombinedState> {
        
        let action = StartSession(
            sessionId: sessionId,
            sessionLabel: sessionLabel,
            taskBuilder: taskBuilder,
            resultsProcessor: resultsProcessor
        )
        
        return Dispatchable(object: action)
        
    }
    
    public static func resumeSession(
        taskBuilder: RSTBTaskBuilder,
        resultsProcessor: RSRPResultsProcessor
        ) -> Dispatchable<RSAFCombinedState> {
        
        let action = ResumeSession(
            taskBuilder: taskBuilder,
            resultsProcessor: resultsProcessor
        )
        
        return Dispatchable(object: action)
        
    }
    
    public static func endCurrentSession(callback:((RSAFCombinedState) -> Void)? = nil) -> Dispatchable<RSAFCombinedState> {
        
        let asyncActionCreator: RSAFActionCreators.AsyncActionCreator = { (state, store, actionCreatorCallback) in
            actionCreatorCallback( { (store, state) in
                return EndSession()
            })
        }
        
        return Dispatchable(object: asyncActionCreator, callback: callback)
    }
    
//    public static func setSessionId(sessionId: String?) -> Action {
//        return SetSessionId(sessionId: sessionId)
//    }
//    
    public static func markResearcherDemographicsCompleted(completed: Bool) -> Dispatchable<RSAFCombinedState> {
        return Dispatchable(object: MarkResearcherDemographicsCompleted(completed: completed))
    }
    
//    public static func setSessionTaskBuilderManager(taskBuilderManager: RSAFTaskBuilderManager) -> Action {
//        return SetSessionTaskBuilderManager(taskBuilderManager: taskBuilderManager)
//    }
//    
//    public static func setSessionResultsProcessorManager(resultsProcessorManager: RSAFResultsProcessorManager) -> Action {
//        return SetSessionResultsProcessorManager(resultsProcessorManager: resultsProcessorManager)
//    }

    public static func setValueInSessionStorage(key: String, value: NSObject?) -> Dispatchable<RSAFCombinedState> {
        return Dispatchable(object: SetValueInSessionStorage(key: key, value: value))
    }
    
}
