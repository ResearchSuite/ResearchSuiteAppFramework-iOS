//
//  RSLOnboardingViewController.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder

open class RSLOnboardingViewController: RSAFRootViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if let delegate = UIApplication.shared.delegate as? RSLApplicationDelegate,
            let item = delegate.signInItem(),
            let store = delegate.reduxStore {
            
            let activityRun = RSAFActivityRun(
                identifier: item.identifier,
                activity: item.activity as JsonElement,
                resultTransforms: item.resultTransforms)
            
            let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
            store.dispatch(action)
            
        }
        
    }

}
