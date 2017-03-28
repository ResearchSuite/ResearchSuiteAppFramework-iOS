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

//    var state: RSAFCombinedState?
    
    override open func viewDidLoad() {
        super.viewDidLoad()

    }

    override open func newState(state: RSAFCombinedState) {
        
        super.newState(state: state)
        
        if let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
            delegate.isSignedIn(state: state),
            let labState = state.middlewareState as? RSLLabState,
            RSLLabSelectors.isResearcherDemographicsCompleted(labState) {
            delegate.showViewController(state: state)
        }
        
    }
    
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
            let item = delegate.signInItem(),
            let store = delegate.reduxStore {
            
            let activityRun = RSAFActivityRun.create(from: item)
            
            let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
            store.dispatch(action)
            
        }
        
    }
}
