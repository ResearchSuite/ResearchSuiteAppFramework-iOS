//
//  RSAFCorePersistentStoreSubscriber.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit

final class RSAFCorePersistentStoreSubscriber: RSAFBasePersistentStoreSubscriber {
    
    static let kExtensibleStorage: String = "ExtensibleStorage"
    let extensibleStorage: RSAFPersistedValueMap
    
    override init(stateManager: RSAFStateManager.Type) {
        self.extensibleStorage = RSAFPersistedValueMap(key: RSAFCorePersistentStoreSubscriber.kExtensibleStorage, stateManager: stateManager)
        super.init(stateManager: stateManager)
    }
    
    open override func loadState() -> RSAFCoreState {
        return RSAFCoreState(extensibleStorage: self.extensibleStorage.get())
    }
    
    open func newState(state: RSAFCoreState) {
        self.extensibleStorage.set(map: RSAFCoreSelectors.getExtensibleStorage(state))
    }
    
//    
//    open override func newState(state: RSAFCoreState) {
//        self.extensibleStorage.set(map: self.selectors.getExtensibleStorage(state))
//    }
}
