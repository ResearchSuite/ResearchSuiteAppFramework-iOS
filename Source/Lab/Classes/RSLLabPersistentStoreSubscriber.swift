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
    
    let researcherDemographicsCompleted: RSAFPersistedValue<Bool>
    let sessionId: RSAFPersistedValue<String>
    
    override public init(stateManager: RSAFStateManager.Type) {
        self.researcherDemographicsCompleted = RSAFPersistedValue<Bool>(key: RSLLabPersistentStoreSubscriber.kResearcherDemographicsCompleted, stateManager: stateManager)
        
        self.sessionId = RSAFPersistedValue<String>(key: RSLLabPersistentStoreSubscriber.kSessionId, stateManager: stateManager)
        
        super.init(stateManager: stateManager)
    }
    
    open override func loadState() -> RSLLabState {
        return RSLLabState(
            researcherDemographicsCompleted: self.researcherDemographicsCompleted.get() ?? false,
            sessionId: self.sessionId.get()
        )
    }
    
    open override func newState(state: RSAFBaseState) {
        if let labState = state as? RSLLabState {
            //            self.extensibleStorage.set(map: RSAFCoreSelectors.getExtensibleStorage(coreState))
            self.researcherDemographicsCompleted.set(value: RSLLabSelectors.isResearcherDemographicsCompleted(labState))
            self.sessionId.set(value: RSLLabSelectors.getSessionId(labState))
        }
    }
}
