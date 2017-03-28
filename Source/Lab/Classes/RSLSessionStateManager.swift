//
//  RSLSessionStateManager.swift
//  Pods
//
//  Created by James Kizer on 3/28/17.
//
//

import UIKit
import ReSwift
import ResearchSuiteTaskBuilder

open class RSLSessionStateManager: NSObject, RSTBStateHelper, StoreSubscriber {

    var valueSelector: ((String) -> NSSecureCoding?)?
    
    let store: Store<RSAFCombinedState>
    
    public init(store: Store<RSAFCombinedState>) {
        self.store = store
        super.init()
    }
    
    open func newState(state: RSAFCombinedState) {
        if let labState = state.middlewareState as? RSLLabState {
            self.valueSelector = RSLLabSelectors.getValueInSessionStorage(labState)
        }
    }
    
    open func setValueInState(value: NSSecureCoding?, forKey: String) {
        self.store.dispatch(RSLLabActionCreators.setValueInSessionStorage(key: forKey, value: value != nil ? value! as? NSObject : nil))
    }
    
    open func valueInState(forKey: String) -> NSSecureCoding? {
        return self.valueSelector?(forKey)
    }
    
    deinit {
        debugPrint("\(self) deiniting")
    }
    
}
