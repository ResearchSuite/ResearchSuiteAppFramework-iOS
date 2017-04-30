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
        let vc = storyboard.instantiateInitialViewController()
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
        
        //check for case where a failure occurs during login
        if isSignedIn(state: state) && !ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            self.signOut()
        }
        
        if !isSignedIn(state: state) && ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            self.signOut()
        }
        
        if !isSignedIn(state: state) || !isResearcherDemographicsCompleted(state: state) {
            if let vc = self.instantiateOnboardingViewController(),
                var rvc = vc as? RSAFRootViewControllerProtocol,
                let coreState = state.coreState as? RSAFCoreState {
                rvc.taskBuilder = RSAFCoreSelectors.getTaskBuilder(coreState)
                rvc.RSAFDelegate = self
                self.transition(toRootViewController: vc, animated: true)
                return
            }
        }
        else {
            if let vc = self.instantiateMainViewController(),
                var rvc = vc as? RSAFRootViewControllerProtocol,
                let coreState = state.coreState as? RSAFCoreState {
                rvc.taskBuilder = RSAFCoreSelectors.getTaskBuilder(coreState)
                rvc.RSAFDelegate = self
                self.transition(toRootViewController: vc, animated: true)
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
    
    open func endSessionItem() -> RSAFScheduleItem? {
        return nil
    }
    
    open func participantSchedule() -> RSAFSchedule? {
        return nil
    }
    
    
}
