//
//  RSLSessionViewController.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import UIKit
import ReSwift
import ResearchSuiteTaskBuilder
import ResearchSuiteResultsProcessor
import ResearchKit

open class RSLSessionViewController: UIViewController, StoreSubscriber {
    
    var sessionId: RSAFObservableValue<String>!
    
    @IBOutlet weak var startSessionButton: UIButton!
    
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    
    var activitiesTVC: RSAFActivityTableViewController?
    
    var sessionTaskBuilder: RSTBTaskBuilder? {
        didSet {
            self.activitiesTVC?.taskBuilder = sessionTaskBuilder
        }
    }
    
    var globalTaskBuilder: RSTBTaskBuilder?
    
    open var store: Store<RSAFCombinedState>? {
        
        guard let delegate = UIApplication.shared.delegate as? RSAFApplicationDelegate else {
            return nil
        }
        
        return delegate.reduxStore
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.sessionId = RSAFObservableValue(initialValue: nil, observationClosure: { (sessionId) in
            if sessionId != nil,
                let activitiesTVC = self.instantiateActivitiesViewController() as? RSAFActivityTableViewController,
                let store = self.store,
                let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
                let schedule = delegate.participantSchedule() {
                activitiesTVC.store = self.store
                activitiesTVC.schedule = schedule
                
                let dispatchableCreator: (UUID, RSAFActivityRun, ORKTaskResult?) -> Dispatchable<RSAFCombinedState>? = { uuid, activityRun, result in
                    
                    if let result = result {
                        return RSAFActionCreators.processResults(
                            uuid: uuid,
                            activityRun: activityRun,
                            taskResult: result,
                            resultsProcessorSelector: { (combinedState) -> RSRPResultsProcessor? in
                            if let labState = combinedState.middlewareState as? RSLLabState {
                                return RSLLabSelectors.getSessionResultsProcessor(labState)
                            }
                            
                            return nil
                        })
                    }
                    else {
                        return nil
                    }
                }
                
                activitiesTVC.resultsDispatchableFunc = dispatchableCreator
                activitiesTVC.taskBuilder = self.sessionTaskBuilder
                
                self.navigationController?.pushViewController(activitiesTVC, animated: true)
                
                activitiesTVC.navigationItem.hidesBackButton = true

                let endSessionButton = UIBarButtonItem(title: "End Session", style: .done, target: self, action: #selector(self.endSession))
                
                activitiesTVC.navigationItem.setRightBarButton(endSessionButton, animated: true)
                self.activitiesTVC = activitiesTVC
            }
        })
        
        self.store?.subscribe(self)
    }
    
    deinit {
        self.store?.unsubscribe(self)
    }
    
    open func instantiateActivitiesViewController() -> UIViewController? {
        let bundle = Bundle(for: RSLSessionViewController.self)
        
        guard let url = bundle.url(forResource: "LabResources", withExtension: "bundle"),
            let resourceBundle = Bundle(url: url) else {
                return nil
        }
        let storyboard = UIStoryboard(name: "RSLMain", bundle: resourceBundle)
        return storyboard.instantiateViewController(withIdentifier: "activities")
    }
    
    
    @IBAction func startSession(_ sender: Any) {
        assert(self.sessionId.get() == nil)
        if let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
            let item = delegate.startSessionItem(),
            let store = delegate.reduxStore,
            let taskBuilder = self.globalTaskBuilder {
            let action = RSAFActionCreators.queueActivity(fromScheduleItem: item, taskBuilder: taskBuilder)
            store.dispatch(action)
            
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        
        assert(self.sessionId.get() == nil)
        
        if let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate  {
            delegate.signOut()
        }
        
    }
    
    open func newState(state: RSAFCombinedState) {
        
        
        guard let labState = state.middlewareState as? RSLLabState,
            let coreState = state.coreState as? RSAFCoreState else {
            return
        }
        
        let sessionId: String? = RSLLabSelectors.getSessionId(labState)
        self.sessionId.set(value: sessionId)
        self.startSessionButton.isEnabled = sessionId == nil
        self.signOutButton.isEnabled = sessionId == nil
        
        self.sessionTaskBuilder = RSLLabSelectors.getSessionTaskBuilder(labState)
        
        self.globalTaskBuilder = RSAFCoreSelectors.getTaskBuilder(coreState)
        
        self.titleLabel.text = RSAFCoreSelectors.getTitleLabelText(coreState)
        self.titleImageView.image = RSAFCoreSelectors.getTitleImage(coreState)
        
    }
    
    func endSession() {
        
        let title = "End Session"
        let message = "Are you sure you want to end the session?"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
//        weak var nav: UINavigationController? = self.navigationController
        
        let endSessionAction = UIAlertAction(title: "End Session", style: .destructive, handler: { _ in
            assert(self.sessionId.get() != nil)
            if let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
                let item = delegate.endSessionItem(),
                let store = delegate.reduxStore,
                let taskBuilder = self.sessionTaskBuilder
            {
                let action = RSAFActionCreators.queueActivity(fromScheduleItem: item, taskBuilder: taskBuilder)
                store.dispatch(action)
                
            }
            
//            if let store = self.store {
//                let asyncActionCreator: RSAFActionCreators.AsyncActionCreator = { (state, store, actionCreatorCallback) in
//                    let endSessionAction = RSLLabActionCreators.endCurrentSession()
//                    actionCreatorCallback( { (store, state) in
//                        return endSessionAction
//                    })
//                    
//                }
//                
//                store.dispatch(asyncActionCreator, callback: { (state) in
//                    nav?.popViewController(animated: true)
//                })
//            }
        })
        alert.addAction(endSessionAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
