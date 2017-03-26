//
//  RSAFRootViewController.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ReSwift
import ResearchSuiteTaskBuilder
import ResearchKit

open class RSAFRootViewController: UIViewController, RSAFRootViewControllerProtocol, StoreSubscriber {

    public var presentedActivity: UUID?
    
    public var contentHidden = false {
        didSet {
            guard contentHidden != oldValue && isViewLoaded else { return }
            
            if let vc = self.presentedViewController {
                vc.view.isHidden = contentHidden
            }
            
            self.view.isHidden = contentHidden
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.store?.subscribe(self)
    }
    
    deinit {
        self.store?.unsubscribe(self)
    }
    
    open func newState(state: RSAFCombinedState) {
        
        if self.presentedActivity == nil,
            let coreState = state.coreState as? RSAFCoreState,
            let (uuid, activityRun) = coreState.activityQueue.first {
            
            self.presentedActivity = uuid
            self.runActivity(uuid: uuid, activityRun: activityRun, completion: { [weak self] in
                self?.presentedActivity = nil
            })
        }
        
    }
    
    

}
