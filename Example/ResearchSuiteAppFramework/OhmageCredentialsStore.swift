//
//  OhmageCredentialsStore.swift
//  ResearchSuiteAppFramework
//
//  Created by James Kizer on 3/25/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import OhmageOMHSDK
import ReSwift
import ResearchSuiteAppFramework

class OhmageCredentialsStore: NSObject, OhmageOMHSDKCredentialStore, StoreSubscriber {
    
    var valueSelector: ((String) -> NSSecureCoding?)?
    
    let store: Store<RSAFCombinedState>
    
    init(store: Store<RSAFCombinedState>) {
        self.store = store
        super.init()
        self.newState(state: store.state)
    }
    
    open func newState(state: RSAFCombinedState) {
        if let coreState = state.coreState as? RSAFCoreState {
            self.valueSelector = RSAFCoreSelectors.getValueInExtensibleStorage(coreState)
        }
    }

    func set(value: NSSecureCoding?, key: String) {
        self.store.dispatch(RSAFActionCreators.setValueInExtensibleStorage(key: key, value: value != nil ? value! as? NSObject : nil))
    }
    func get(key: String) -> NSSecureCoding? {
        return self.valueSelector?(key)
    }

    deinit {
        debugPrint("\(self) deiniting")
    }

}
