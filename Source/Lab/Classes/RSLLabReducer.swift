//
//  RSLLabReducer.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import UIKit
import ReSwift

open class RSLLabReducer: RSAFBaseReducer {
    
    public static let reducer = LabStateReducer()
    
    open override func handleAction(action: Action, state: RSAFBaseState?) -> RSAFBaseState {
        return RSLLabReducer.reducer._handleAction(action: action, state: state) as! RSAFBaseState
    }
    
    final public class LabStateReducer: RSAFBaseReducer {
        open override func handleAction(action: Action, state: RSAFBaseState?) -> RSAFBaseState {
            let state = (state ?? RSLLabState.empty()) as! RSLLabState
            
            switch action {
                
            case let demographicsCompletedAction as MarkResearcherDemographicsCompleted:
                return RSLLabState.newState(fromState: state, researcherDemographicsCompleted: demographicsCompletedAction.completed)
                
            case let startSessionAction as StartSession:
                return RSLLabState.newState(
                    fromState: state,
                    sessionId: startSessionAction.sessionId,
                    sessionStorage: [:],
                    sessionTaskBuilder: startSessionAction.taskBuilderManager,
                    sessionResultsProcessor: startSessionAction.resultsProcessorManager
                )
                
            case let endSessionAction as EndSession:
                return RSLLabState.newState(
                    fromState: state,
                    sessionId: nil as String?,
                    sessionStorage: [:],
                    sessionTaskBuilder: nil as RSAFTaskBuilderManager?,
                    sessionResultsProcessor: nil as RSAFResultsProcessorManager?
                )
                
            case let setValueAction as SetValueInSessionStorage:
                
                var sessionStorageDict: [String: NSObject] = state.sessionStorage
                
                let key = setValueAction.key
                
                if let value = setValueAction.value {
                    sessionStorageDict[key] = value
                }
                else {
                    sessionStorageDict.removeValue(forKey: key)
                }
                
                return RSLLabState.newState(
                    fromState: state,
                    sessionStorage: sessionStorageDict
                )
                
            default:
                return state
            }
        }
        
    }

}
