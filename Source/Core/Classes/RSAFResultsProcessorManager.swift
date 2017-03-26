//
//  RSAFResultsProcessorManager.swift
//  Pods
//
//  Created by James Kizer on 3/25/17.
//
//

import UIKit
import ResearchSuiteResultsProcessor
import ReSwift
import ResearchKit

open class RSAFResultsProcessorManager: NSObject, StoreSubscriber {
    
    var _pendingResult: (UUID, RSAFActivityRun, ORKTaskResult)? = nil
    
    var pendingResult: (UUID, RSAFActivityRun, ORKTaskResult)? {
        get {
            return _pendingResult
        }
        set(newPendingResult) {
            if newPendingResult?.0 != _pendingResult?.0 {
                _pendingResult = newPendingResult
                if let result = _pendingResult {
                    self.processResult(
                        uuid: result.0,
                        activityRun: result.1,
                        taskResult: result.2)
                }
                
            }
        }
    }
    
    let rsrp: RSRPResultsProcessor
    let store: Store<RSAFCombinedState>
    
    open class func frontEndTransformers() -> [RSRPFrontEndTransformer.Type] {
        return []
    }
    
    init(store: Store<RSAFCombinedState>, backEnd: RSRPBackEnd) {
        
        self.rsrp = RSRPResultsProcessor(
            frontEndTransformers: RSAFResultsProcessorManager.frontEndTransformers(),
            backEnd: backEnd
        )
        
        self.store = store
        super.init()
        store.subscribe(self)
        
    }
    
    deinit {
        store.unsubscribe(self)
    }
    
    func processResult(uuid: UUID, activityRun: RSAFActivityRun, taskResult: ORKTaskResult) {
        
        //process result
        
        if let resultTransforms = activityRun.resultTransforms {
            self.rsrp.processResult(taskResult: taskResult, resultTransforms: resultTransforms)
        }
        
        self.pendingResult = nil
        let action = ResultsProcessedAction(uuid: uuid)
        store.dispatch(action)
        
    }
    
    public func newState(state: RSAFCombinedState) {
        if let coreState = state.coreState as? RSAFCoreState {
            self.pendingResult = coreState.resultsQueue.first
        }
    }
    

}
