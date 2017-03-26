//
//  RSAFRootViewController.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ReSwift
import ResearchKit
import ResearchSuiteTaskBuilder

public protocol RSAFRootViewControllerProtocol {
    
    var contentHidden: Bool { get set }
    var presentedActivity: UUID? { get set }
    
    var store: Store<RSAFCombinedState>? { get }
    var taskBuilder: RSTBTaskBuilder? { get }
    func runActivity(uuid: UUID, activityRun: RSAFActivityRun, completion: @escaping ()->Void)
    
}

extension RSAFRootViewControllerProtocol {
    
    public var store: Store<RSAFCombinedState>? {
        return nil
    }
    
    public var taskBuilder: RSTBTaskBuilder? {
        return nil
    }
    
    public func runActivity(uuid: UUID, activityRun: RSAFActivityRun, completion: @escaping ()->Void) {
        
        guard let vcSelf = self as? UIViewController,
            let steps = self.taskBuilder?.steps(forElement: activityRun.activity) else {
            return
        }
        
        let task = ORKOrderedTask(identifier: activityRun.identifier, steps: steps)
        
        let store = self.store
        
        let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { [weak vcSelf] (taskViewController, reason, error) in
            
            let taskResult: ORKTaskResult? = (reason == ORKTaskViewControllerFinishReason.completed) ?
                taskViewController.result : nil
            
            store?.dispatch(RSAFActionCreators.completeActivity(uuid: uuid, activityRun: activityRun, taskResult: taskResult), callback: { (state) in
                
                vcSelf?.dismiss(animated: true, completion: completion)
            })
            
        }
        
        let taskViewController = RSAFTaskViewController(activityUUID: uuid, task: task, taskFinishedHandler: taskFinishedHandler)
        
        
        vcSelf.present(taskViewController, animated: true, completion: nil)
        
    }
}
