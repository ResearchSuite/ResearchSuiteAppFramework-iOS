//
//  AppDelegate.swift
//  ResearchSuiteAppFramework
//
//  Created by jdkizer9 on 03/22/2017.
//  Copyright (c) 2017 jdkizer9. All rights reserved.
//

import UIKit
import ResearchSuiteAppFramework
import OhmageOMHSDK
import ResearchSuiteTaskBuilder
import ReSwift
import ResearchKit

@UIApplicationMain
final class AppDelegate: RSLApplicationDelegate {
    
    var ohmageManager: OhmageOMHManager!
    var credentialsStore: OhmageCredentialsStore!
    var onboardingSchedule: RSAFSchedule?

    open override func loadCombinedReducer() -> RSAFCombinedReducer {
        return RSAFCombinedReducer(
            coreReducer: RSAFCoreReducer(),
            middlewareReducer: RSLLabReducer(),
            appReducer: RSAFBaseReducer()
        )
    }
    
    open override func loadPersistenceManager(stateManager: RSAFStateManager.Type) -> RSAFCombinedPersistentStoreSubscriber {
        return RSAFCombinedPersistentStoreSubscriber(
            coreSubscriber: RSAFCorePersistentStoreSubscriber(stateManager: stateManager),
            middlewareSubscriber: RSLLabPersistentStoreSubscriber(stateManager: stateManager),
            appSubscriber: RSAFBasePersistentStoreSubscriber(stateManager: stateManager)
        )
    }
    
    func initializeOhmage(credentialsStore: OhmageCredentialsStore) -> OhmageOMHManager {
        
        guard let store = self.reduxStore,
            let file = Bundle.main.path(forResource: "OMHClient", ofType: "plist") else {
                fatalError("Could not initialze OhmageManager")
        }
        
        let omhClientDetails = NSDictionary(contentsOfFile: file)
        
        guard let baseURL = omhClientDetails?["OMHBaseURL"] as? String,
            let clientID = omhClientDetails?["OMHClientID"] as? String,
            let clientSecret = omhClientDetails?["OMHClientSecret"] as? String else {
                fatalError("Could not initialze OhmageManager")
        }
        
        let credentialsStore = OhmageCredentialsStore(store: store)
        
        if OhmageOMHManager.config(baseURL: baseURL,
                                   clientID: clientID,
                                   clientSecret: clientSecret,
                                   queueStorageDirectory: "ohmageSDK",
                                   store: credentialsStore) {
            return OhmageOMHManager.shared
        }
        else {
            fatalError("Could not initialze OhmageManager")
        }
        
    }
    
    open override func initializeStore() -> Store<RSAFCombinedState> {
        
        let store = super.initializeStore()
        
        self.credentialsStore = OhmageCredentialsStore(store: store)
        self.ohmageManager = self.initializeOhmage(credentialsStore: self.credentialsStore)
        self.onboardingSchedule = self.loadSchedule(filename: "onboardingSchedule")
        
        return store
    }
    
    open override func subscribeToStore(store: Store<RSAFCombinedState>) {
        store.subscribe(self.credentialsStore)
        super.subscribeToStore(store: store)
    }
    
    open override func resetStore() {
        self.ohmageManager = nil
        self.credentialsStore = nil
        super.resetStore()
    }
    
    open override func unsubscribeFromStore(store: Store<RSAFCombinedState>) {
        store.unsubscribe(self.credentialsStore)
        super.unsubscribeFromStore(store: store)
    }
    
    open override func participantSchedule() -> RSAFSchedule? {
        return self.loadSchedule(filename: "participantSchedule")
    }
    
    open override func signInItem() -> RSAFScheduleItem? {
        guard let onboardingSchedule = self.onboardingSchedule,
            let item = onboardingSchedule.itemMap["sign_in"] else {
                return nil
        }
        
        let actionCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Action? = { uuid, activityRun, result in
            guard let item = self.researcherDemographics() else {
                return nil
            }
            let researcherDemographicsActivityRun = RSAFActivityRun.create(from: item)
            
            return RSAFActionCreators.queueActivity(uuid: UUID(), activityRun: researcherDemographicsActivityRun)
        }
        
        item.onCompletionActionCreators = [actionCreator]
        
        return item
    }
    
    open override func researcherDemographics() -> RSAFScheduleItem? {
        guard let onboardingSchedule = self.onboardingSchedule,
            let item = onboardingSchedule.itemMap["researcher_demographics"] else {
                return nil
        }
        
        let actionCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Action? = { uuid, activityRun, result in
            if result != nil {
                return RSLLabActionCreators.markResearcherDemographicsCompleted(completed: true)
            }
            else {
                return nil
            }
        }
        
        item.onCompletionActionCreators = [actionCreator]
        
        return item
    }
    
    //on completion, this launches the participant demographics
//    open func startSessionItem() -> RSAFScheduleItem? {
//        return nil
//    }
    open override func startSessionItem() -> RSAFScheduleItem? {
        guard let onboardingSchedule = self.onboardingSchedule,
            let item = onboardingSchedule.itemMap["start_session"] else {
                return nil
        }
        
        let actionCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Action? = { uuid, activityRun, result in
            guard let item = self.participantDemographics(withSessionId: uuid) else {
                return nil
            }
  
            let nestedActivityRun = RSAFActivityRun.create(from: item)
            
            return RSAFActionCreators.queueActivity(uuid: UUID(), activityRun: nestedActivityRun)
        }
        
        item.onCompletionActionCreators = [actionCreator]
        
        return item
    }
    
    
    //on completion, this sets the session id
    func participantDemographics(withSessionId sessionId: UUID) -> RSAFScheduleItem? {
        
        if let item = participantDemographics() {
            
            let actionCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Action? = { uuid, activityRun, result in
                if result != nil {
                    return RSLLabActionCreators.setSessionId(sessionId: sessionId.uuidString)
                }
                else {
                    return RSLLabActionCreators.setSessionId(sessionId: nil)
                }
                
            }
            
            item.onCompletionActionCreators = [actionCreator]
            
            return item
            
        }
        else {
            return nil
        }
    
    }
    open override func participantDemographics() -> RSAFScheduleItem? {
        guard let onboardingSchedule = self.onboardingSchedule,
            let item = onboardingSchedule.itemMap["participant_demographics"] else {
                return nil
        }
        return item
    }
    
    open override func signOut() {
        self.ohmageManager.signOut { (error) in
            super.signOut()
        }
    }
    
    open override func isSignedIn(state: RSAFCombinedState) -> Bool {
        return self.ohmageManager.isSignedIn
    }
    
    open override func createTaskBuilderManager(stateHelper: RSTBStateHelper) -> RSAFTaskBuilderManager {
        return RSAFAppTaskBuilderManager(stateHelper: stateHelper)
    }

}

