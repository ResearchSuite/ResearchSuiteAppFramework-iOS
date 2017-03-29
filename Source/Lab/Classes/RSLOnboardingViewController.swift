//
//  RSLOnboardingViewController.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder
import ReSwift

open class RSLOnboardingViewController: RSAFRootViewController {

    private var state: RSAFCombinedState?
    private var showingVC = false
    override open func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    

    override open func newState(state: RSAFCombinedState) {
        
        super.newState(state: state)
        
        self.state = state
        
        if !showingVC,
            let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
            delegate.isSignedIn(state: state),
            let labState = state.middlewareState as? RSLLabState,
            RSLLabSelectors.isResearcherDemographicsCompleted(labState) {
            showingVC = true
            delegate.showViewController(state: state)
        }
        
    }
    
    
    @IBAction func signInTapped(_ sender: Any) {
        
        guard let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
            let store = delegate.reduxStore,
            let state = self.state else {
            return
        }
        
        if !delegate.isSignedIn(state: state),
            let item = delegate.signInItem() {
            let activityRun = RSAFActivityRun.create(from: item)
            let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
            store.dispatch(action)
        }
        else if !delegate.isResearcherDemographicsCompleted(state: state),
            let item = delegate.researcherDemographics() {
            let activityRun = RSAFActivityRun.create(from: item)
            let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
            store.dispatch(action)
        }
        
    }
}
