//
//  RSAFLabPersistentStoreSubscriber.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import UIKit

final public class RSLLabPersistentStoreSubscriber: RSAFBasePersistentStoreSubscriber {
    static let kResearcherDemographicsCompleted: String = "ResearcherDemographicsCompleted"
    static let kSessionId: String = "SessionId"
    static let kSessionLabel: String = "SessionLabel"
    static let kSessionStorage: String = "SessionStorage"
    
    let researcherDemographicsCompleted: RSAFPersistedValue<Bool>
    let sessionId: RSAFPersistedValue<String>
    let sessionLabel: RSAFPersistedValue<String>
    let sessionStorage: RSAFPersistedValueMap
    
    override public init(stateManager: RSAFStateManager.Type) {
        self.researcherDemographicsCompleted = RSAFPersistedValue<Bool>(key: RSLLabPersistentStoreSubscriber.kResearcherDemographicsCompleted, stateManager: stateManager)
        
        self.sessionId = RSAFPersistedValue<String>(key: RSLLabPersistentStoreSubscriber.kSessionId, stateManager: stateManager)
        self.sessionLabel = RSAFPersistedValue<String>(key: RSLLabPersistentStoreSubscriber.kSessionId, stateManager: stateManager)
        
        self.sessionStorage = RSAFPersistedValueMap(key: RSLLabPersistentStoreSubscriber.kSessionStorage, stateManager: stateManager)
        
        super.init(stateManager: stateManager)
    }
    
    open override func loadState() -> RSLLabState {
        return RSLLabState(
            researcherDemographicsCompleted: self.researcherDemographicsCompleted.get() ?? false,
            sessionId: self.sessionId.get(),
            sessionLabel: self.sessionLabel.get(),
            sessionStorage: self.sessionStorage.get()
        )
    }
    
    open override func newState(state: RSAFBaseState) {
        if let labState = state as? RSLLabState {
            //            self.extensibleStorage.set(map: RSAFCoreSelectors.getExtensibleStorage(coreState))
            self.researcherDemographicsCompleted.set(value: RSLLabSelectors.isResearcherDemographicsCompleted(labState))
            self.sessionId.set(value: RSLLabSelectors.getSessionId(labState))
            self.sessionLabel.set(value: RSLLabSelectors.getSessionLabel(labState))
            self.sessionStorage.set(map: RSLLabSelectors.getSessionStorage(labState))
        }
    }
}
