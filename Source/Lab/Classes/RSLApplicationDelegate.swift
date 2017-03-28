//
//  RSLApplicationDelegate.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ResearchKit
import Gloss
import ResearchSuiteTaskBuilder

open class RSLApplicationDelegate: RSAFApplicationDelegate {

    override open func instantiateOnboardingViewController() -> UIViewController? {
        let bundle = Bundle(for: RSLApplicationDelegate.self)
        
        guard let url = bundle.url(forResource: "LabResources", withExtension: "bundle"),
            let resourceBundle = Bundle(url: url) else {
            return nil
        }
        let storyboard = UIStoryboard(name: "RSLOnboarding", bundle: resourceBundle)
        return storyboard.instantiateInitialViewController()
    }
    
    override open func instantiateMainViewController() -> UIViewController? {
        let bundle = Bundle(for: RSLApplicationDelegate.self)
        
        guard let url = bundle.url(forResource: "LabResources", withExtension: "bundle"),
            let resourceBundle = Bundle(url: url) else {
                return nil
        }
        let storyboard = UIStoryboard(name: "RSLMain", bundle: resourceBundle)
        let vc = storyboard.instantiateInitialViewController()
        return vc
    }
    
    
    open func isResearcherDemographicsCompleted(state: RSAFCombinedState) -> Bool {
        guard let labState = state.middlewareState as? RSLLabState else {
            return false
        }
        return RSLLabSelectors.isResearcherDemographicsCompleted(labState)
    }
    
    open override func showViewController(state: RSAFCombinedState) {
        
        guard let window = self.window else {
                return
        }
        
        //check for case where a failure occurs during login
        if isSignedIn(state: state) && !ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            self.signOut()
        }
        
        if !isSignedIn(state: state) {
            if let vc = self.instantiateOnboardingViewController(),
                vc as? RSAFRootViewControllerProtocol != nil {
                window.rootViewController = vc
                return
            }
        }
        else if !isResearcherDemographicsCompleted(state: state) {
            assert(isSignedIn(state: state))
            if window.rootViewController as? RSAFRootViewControllerProtocol == nil {
                if let vc = self.instantiateOnboardingViewController(),
                    vc as? RSAFRootViewControllerProtocol != nil {
                    window.rootViewController = vc
                }
            }
            //mount base vc
            //emit demographics action
//            if let item = self.researcherDemographics(),
//                let store = self.reduxStore {
//                
//                let activityRun = RSAFActivityRun(
//                    identifier: item.identifier,
//                    activity: item.activity as JsonElement,
//                    resultTransforms: item.resultTransforms)
//                
//                let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
//                store.dispatch(action)
//            }
            
        }
                
        else {
            if let vc = self.instantiateMainViewController(),
                vc as? RSAFRootViewControllerProtocol != nil {
                window.rootViewController = vc
                return
            }
        }
        
    }
    
    open func signInItem() -> RSAFScheduleItem? {
        return nil
    }
    
    open func researcherDemographics() -> RSAFScheduleItem? {
        return nil
    }
    
    open func participantDemographics() -> RSAFScheduleItem? {
        return nil
    }
    
    open func startSessionItem() -> RSAFScheduleItem? {
        return nil
    }
    
    open func participantSchedule() -> RSAFSchedule? {
        return nil
    }
    
    
}
