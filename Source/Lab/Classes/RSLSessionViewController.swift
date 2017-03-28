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

open class RSLSessionViewController: UIViewController, StoreSubscriber {
    
    var sessionId: RSAFObservableValue<String>?
    
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
                self.navigationController?.pushViewController(activitiesTVC, animated: true)
                
                activitiesTVC.navigationItem.hidesBackButton = true
                let endSessionButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.endSession))
                
                activitiesTVC.navigationItem.setRightBarButton(endSessionButton, animated: true)
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
        if let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
            let item = delegate.startSessionItem(),
            let store = delegate.reduxStore {
            
            let activityRun = RSAFActivityRun.create(from: item)
            
            let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
            store.dispatch(action)
            
        }
    }
    
    open func newState(state: RSAFCombinedState) {
        
        let sessionId: String? = {
            
            guard let labState = state.middlewareState as? RSLLabState else {
                return nil
            }
            
            return RSLLabSelectors.getSessionId(labState)
        }()
        
        self.sessionId?.set(value: sessionId)
    }
    
    func endSession() {
        
        let title = "End Session"
        let message = "Are you sure you want to end the session?"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        weak var nav: UINavigationController? = self.navigationController
        
        let endSessionAction = UIAlertAction(title: "End Session", style: .destructive, handler: { _ in
            if let store = self.store {
                let asyncActionCreator: RSAFActionCreators.AsyncActionCreator<RSAFCombinedState> = { (state, store, actionCreatorCallback) in
                    let endSessionAction = RSLLabActionCreators.endCurrentSession()
                    actionCreatorCallback( { (store, state) in
                        return endSessionAction
                    })
                    
                }
                
                store.dispatch(asyncActionCreator, callback: { (state) in
                    nav?.popViewController(animated: true)
                })
            }
        })
        alert.addAction(endSessionAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
