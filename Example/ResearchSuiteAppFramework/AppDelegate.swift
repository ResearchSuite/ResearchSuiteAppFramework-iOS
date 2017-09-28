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
import ResearchSuiteResultsProcessor
import sdlrkx
import ResearchSuiteExtensions

@UIApplicationMain
final class AppDelegate: RSLApplicationDelegate {
    
    var ohmageManager: OhmageOMHManager!
    var credentialsStore: OhmageCredentialsStore!
    var onboardingSchedule: RSAFSchedule?
    
    var sessionOhmageBackend: ORBEManager!
    var sessionStateManager: RSLSessionStateManager?

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
        
        if let ohmageManager = OhmageOMHManager(baseURL: baseURL,
                                   clientID: clientID,
                                   clientSecret: clientSecret,
                                   queueStorageDirectory: "ohmageSDK",
                                   store: credentialsStore) {
            return ohmageManager
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
        
        store.dispatch(
            RSAFActionCreators.createTaskBuilder(
                stateHelper: self.extensibleStateManager,
                elementGeneratorServices: AppDelegate.elementGeneratorServices,
                stepGeneratorServices: AppDelegate.stepGeneratorServices,
                answerFormatGeneratorServices: AppDelegate.answerFormatGeneratorServices
            )
        )
        
        store.dispatch(
            RSAFActionCreators.createResultsProcessor(
                frontEndTransformers: AppDelegate.resultsProcessorFrontEndTransformers,
                backEnds: [
                    ORBEManager(ohmageManager: self.ohmageManager),
                    RSAFFakeBackEnd()
                ]
            )
        )
        
        
        //check to see if we should create session as well
        
        if let labState = store.state.middlewareState as? RSLLabState,
            RSLLabSelectors.getSessionId(labState) != nil {
            let sessionStateManager = RSLSessionStateManager(store: store)
            self.sessionStateManager = sessionStateManager
            
            self.sessionOhmageBackend =  {
                
                if let sessionLabel: String = RSLLabSelectors.getSessionLabel(labState) {
                    let metadata = ["session_label": sessionLabel]
                    return ORBEManager(ohmageManager: self.ohmageManager, metadata: metadata)
                }
                else {
                    return ORBEManager(ohmageManager: self.ohmageManager)
                }
                
            }()
            
            store.subscribe(sessionStateManager)
            let taskBuilder = RSTBTaskBuilder(
                stateHelper: sessionStateManager,
                elementGeneratorServices: AppDelegate.elementGeneratorServices,
                stepGeneratorServices: AppDelegate.stepGeneratorServices,
                answerFormatGeneratorServices: AppDelegate.answerFormatGeneratorServices
            )
            
            let resultsProcessor = RSRPResultsProcessor(
                frontEndTransformers: AppDelegate.resultsProcessorFrontEndTransformers,
                backEnds: [
                    self.sessionOhmageBackend,
                    RSAFFakeBackEnd()
                ]
            )
            
            //we're not actually starting a session here, as it's already started
            //just need to set task builder and results processor
            store.dispatch(RSLLabActionCreators.resumeSession(
                taskBuilder: taskBuilder,
                resultsProcessor: resultsProcessor
            ))
        }
        
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
    
    func launchItemAction(itemFunc : @escaping ()->RSAFScheduleItem?, useSessionTaskBuilder: Bool) -> (UUID, RSAFActivityRun, ORKTaskResult?) -> Dispatchable<RSAFCombinedState>? {
        let actionCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Dispatchable<RSAFCombinedState>? = { uuid, activityRun, result in
            guard result != nil,
                let item = itemFunc() else {
                    return nil
            }
            return RSAFActionCreators.queueActivity(
                fromScheduleItem: item, taskBuilderSelector: { (combinedState) -> RSTBTaskBuilder? in
                    if useSessionTaskBuilder {
                        if let labState = combinedState.middlewareState as? RSLLabState,
                            let taskBuilder = RSLLabSelectors.getSessionTaskBuilder(labState) {
                            return taskBuilder
                        }
                        else {
                            return nil
                        }
                    }
                    else {
                        if let coreState = combinedState.coreState as? RSAFCoreState,
                            let taskBuilder = RSAFCoreSelectors.getTaskBuilder(coreState) {
                            return taskBuilder
                        }
                        return nil
                    }
                    
            })
        }
        return actionCreator
    }
    
    func processResults(useSessionResultsProcessor: Bool) -> (UUID, RSAFActivityRun, ORKTaskResult?) -> Dispatchable<RSAFCombinedState>? {
        let dispatchableCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Dispatchable<RSAFCombinedState>? = { uuid, activityRun, result in
            
            
            if let result = result {
                return RSAFActionCreators.processResults(
                    uuid: uuid,
                    activityRun: activityRun,
                    taskResult: result,
                    resultsProcessorSelector: { (combinedState) -> RSRPResultsProcessor? in
                        
                        if useSessionResultsProcessor {
                            if let labState = combinedState.middlewareState as? RSLLabState {
                                return RSLLabSelectors.getSessionResultsProcessor(labState)
                            }
                            
                            return nil
                        }
                        else {
                            if let coreState = combinedState.coreState as? RSAFCoreState {
                                return RSAFCoreSelectors.getResultsProcessor(coreState)
                            }
                            
                            return nil
                        }
                        
                })
            }
            else {
                return nil
            }
        }
        
        return dispatchableCreator
    }
    
    
    //TODO: Need to figure out how to handle case where the task builder
    //fails to generate the log in step!
    open override func signInItem() -> RSAFScheduleItem? {
        guard let onboardingSchedule = self.onboardingSchedule,
            let item = onboardingSchedule.itemMap["sign_in"] else {
                return nil
        }
        
        item.onCompletionActionCreators = [
            launchItemAction(itemFunc: self.researcherDemographics, useSessionTaskBuilder: false)
        ]
        
        return item
    }
    
    open override func researcherDemographics() -> RSAFScheduleItem? {
        guard let onboardingSchedule = self.onboardingSchedule,
            let item = onboardingSchedule.itemMap["researcher_demographics"] else {
                return nil
        }
        
        let actionCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Dispatchable<RSAFCombinedState>? = { uuid, activityRun, result in
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
    
    //also, we should clear the session store
    open override func startSessionItem() -> RSAFScheduleItem? {
        guard let onboardingSchedule = self.onboardingSchedule,
            let item = onboardingSchedule.itemMap["start_session"] else {
                return nil
        }

        item.onCompletionActionCreators = [
            self.startSession(),
            launchItemAction(itemFunc: self.participantDemographics, useSessionTaskBuilder: false)
        ]
        
        return item
    }
    
    open override func endSessionItem() -> RSAFScheduleItem? {
        guard let onboardingSchedule = self.onboardingSchedule,
            let item = onboardingSchedule.itemMap["end_session"] else {
                return nil
        }
        
        let actionCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Dispatchable<RSAFCombinedState>? = { uuid, activityRun, result in
            
            return RSLLabActionCreators.endCurrentSession(callback: { (state) in
                
                let dispatchable = RSLLabActionCreators.endCurrentSession(callback: { (state) in
                    
                    if let navVC = self.window?.rootViewController as? RSAFRootNavigationControllerViewController {
                        navVC.popViewController(animated: true)
                    }
                    
                })
                
                self.reduxStore?.dispatch(dispatchable)
                
            })
            
        }
        
        item.onCompletionActionCreators = [actionCreator]
        
        return item
    }
    
    
    //on completion, this sets the session id
    open override func participantDemographics() -> RSAFScheduleItem? {
        
        guard let onboardingSchedule = self.onboardingSchedule,
            let item = onboardingSchedule.itemMap["participant_demographics"] else {
                return nil
        }
        
        item.onCompletionActionCreators = [
            self.processResults(useSessionResultsProcessor: true)
        ]
        
        return item
    
    }

    func startSession() -> (UUID, RSAFActivityRun, ORKTaskResult?) -> Dispatchable<RSAFCombinedState>? {
        
        let dispatchableCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Dispatchable<RSAFCombinedState>? = { uuid, activityRun, result in
            if result != nil,
                let store = self.reduxStore {
                
                let sessionLabel: String? = {
                    let stepResult: ORKStepResult? = result?.stepResult(forStepIdentifier: "session_label")
                    let textResult: ORKTextQuestionResult? = stepResult?.firstResult as? ORKTextQuestionResult
                    return textResult?.textAnswer
                }()
                
                let sessionStateManager = RSLSessionStateManager(store: store)
                self.sessionStateManager = sessionStateManager
                store.subscribe(sessionStateManager)
                let taskBuilder = RSTBTaskBuilder(
                    stateHelper: sessionStateManager,
                    elementGeneratorServices: AppDelegate.elementGeneratorServices,
                    stepGeneratorServices: AppDelegate.stepGeneratorServices,
                    answerFormatGeneratorServices: AppDelegate.answerFormatGeneratorServices
                )
                
                self.sessionOhmageBackend =  {
                    
                    if let sessionLabel = sessionLabel {
                        let metadata = ["session_label": sessionLabel]
                        return ORBEManager(ohmageManager: self.ohmageManager, metadata: metadata)
                    }
                    else {
                        return ORBEManager(ohmageManager: self.ohmageManager)
                    }
                    
                }()
                
                let resultsProcessor = RSRPResultsProcessor(
                    frontEndTransformers: AppDelegate.resultsProcessorFrontEndTransformers,
                    backEnds: [
                        self.sessionOhmageBackend,
                        RSAFFakeBackEnd()
                    ]
                )
                
                return RSLLabActionCreators.startSession(
                    sessionId: uuid.uuidString,
                    sessionLabel: sessionLabel,
                    taskBuilder: taskBuilder,
                    resultsProcessor: resultsProcessor
                )
            }
            else {
                return RSLLabActionCreators.endCurrentSession()
            }
            
        }
        
        return dispatchableCreator
    }
    
    open override func signOut() {
        self.ohmageManager.signOut { (error) in
            super.signOut()
        }
    }
    
    open override func isSignedIn(state: RSAFCombinedState) -> Bool {
        return self.ohmageManager.isSignedIn
    }
    
    open override func createExtensibleStateManager(store: Store<RSAFCombinedState>) -> RSAFExtensibleStateManager {
        return OhmageExtensibleStateManager(store: store, ohmageManagerClosure: { [weak self] () -> OhmageOMHManager? in
            self?.ohmageManager
        })
    }
    
    override open class var stepGeneratorServices: [RSTBStepGenerator] {
        return [
            CTFOhmageLoginStepGenerator(),
            RSQuestionTableViewStepGenerator(),
            RSEnhancedSingleChoiceStepGenerator(),
            RSEnhancedMultipleChoiceStepGenerator()
            ] + super.stepGeneratorServices
    }
    
    override open class var resultsProcessorFrontEndTransformers: [RSRPFrontEndTransformer.Type] {
        return [] + super.resultsProcessorFrontEndTransformers
    }
    
    override open var titleLabelText: String? {
        return "Research Suite"
    }
    
    override open var titleImage: UIImage? {
        return nil
    }

}

