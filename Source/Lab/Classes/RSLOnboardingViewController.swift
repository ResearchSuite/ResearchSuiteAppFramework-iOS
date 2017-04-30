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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    
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
        
        guard let coreState = state.coreState as? RSAFCoreState else {
            return
        }
        
        self.titleLabel.text = RSAFCoreSelectors.getTitleLabelText(coreState)
        self.titleImageView.image = RSAFCoreSelectors.getTitleImage(coreState)
        
    }
    
    
    
    
    @IBAction func signInTapped(_ sender: Any) {
        
        guard let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
            let store = delegate.reduxStore,
            let state = self.state else {
            return
        }
        
        if !delegate.isSignedIn(state: state),
            let item = delegate.signInItem(),
            let taskBuilder = self.taskBuilder {
//            let activityRun = RSAFActivityRun.create(from: item)
//            let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
            let action = RSAFActionCreators.queueActivity(fromScheduleItem: item, taskBuilder: taskBuilder)
            store.dispatch(action)
        }
        else if !delegate.isResearcherDemographicsCompleted(state: state),
            let item = delegate.researcherDemographics(),
            let taskBuilder = self.taskBuilder  {
//            let activityRun = RSAFActivityRun.create(from: item)
//            let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
            let action = RSAFActionCreators.queueActivity(fromScheduleItem: item, taskBuilder: taskBuilder)
            store.dispatch(action)
        }
        
    }
}
