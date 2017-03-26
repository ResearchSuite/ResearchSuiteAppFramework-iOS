//
//  OhmageReducer.swift
//  ResearchSuiteAppFramework
//
//  Created by James Kizer on 3/25/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ResearchSuiteAppFramework
import ReSwift

open class OhmageReducer: RSAFBaseReducer {
    
    func handleAction(action: Action, state: OhmageOMHSSDKState?) -> OhmageOMHSSDKState {
        let state = state ?? OhmageOMHSSDKState.empty()
        
        switch action {
            
        case let loggedInAction as SetLoggedInAction:
            return RSAFCoreState.newState(fromState: state, loggedIn: loggedInAction.loggedIn)
            
        default:
            return state
        }
        
    }

}
