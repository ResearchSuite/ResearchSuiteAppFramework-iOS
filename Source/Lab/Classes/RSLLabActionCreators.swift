//
//  RSLLabActionCreators.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import UIKit
import ReSwift

public class RSLLabActionCreators: NSObject {
    
    public static func setSessionId(sessionId: String?) -> Action {
        return SetSessionId(sessionId: sessionId)
    }
    
    public static func markResearcherDemographicsCompleted(completed: Bool) -> Action {
        return MarkResearcherDemographicsCompleted(completed: completed)
    }

}
