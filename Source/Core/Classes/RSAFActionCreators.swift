//
//  RSAFActionCreators.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ReSwift
import ResearchKit

open class RSAFActionCreators: NSObject {
    
//    associatedtype RSAFStateType: StateType
    public typealias ActionCreator<T: StateType> = (_ state: T, _ store: Store<T>) -> Action?
    public typealias AsyncActionCreator<T: StateType> = (
        _ state: T,
        _ store: Store<T>,
        _ actionCreatorCallback: @escaping ((ActionCreator<T>) -> Void)
        ) -> Void
    
    
    public static func setLoggedIn<T>(loggedIn: Bool) -> AsyncActionCreator<T> {
        return { (state, store, actionCreatorCallback) in
            
            let loggedInAction = SetLoggedInAction(loggedIn: loggedIn)
            actionCreatorCallback( { (store, state) in
                return loggedInAction
            })
            
        }
    }
    
    public static func queueActivity(uuid: UUID, activityRun: RSAFActivityRun) -> Action {
        return QueueActivityAction(uuid: uuid, activityRun: activityRun)
    }
    
    public static func completeActivity<T>(uuid: UUID, activityRun: RSAFActivityRun, taskResult: ORKTaskResult?) -> AsyncActionCreator<T> {
        return { (state, store, actionCreatorCallback) in
            
            if let onCompletionActionCreators = activityRun.onCompletionActionCreators {
                let actions = onCompletionActionCreators.flatMap({ (creator) -> Action? in
                    return creator(uuid, activityRun, taskResult)
                })
                actions.forEach({ (action) in
                    store.dispatch(action)
                })
            }
            
            let completeAction = CompleteActivityAction(uuid: uuid, activityRun: activityRun, taskResult: taskResult)
            actionCreatorCallback( { (store, state) in
                return completeAction
            })
            
        }
    }
    
    public static func setValueInExtensibleStorage(key: String, value: NSObject?) -> (RSAFCombinedState, Store<RSAFCombinedState>) -> Action? {
        
        return { (state, store) in
            return SetValueInExtensibleStorage(key: key, value: value)
        }
        
    }
    
    public static func clearStore() -> (RSAFCombinedState, Store<RSAFCombinedState>) -> Action? {
        return { (state, store) in
            return ClearStore()
        }
    }

}
