//
//  RSAFActivityRun.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchSuiteResultsProcessor

public struct RSAFActivityRun {
    
    let identifier: String
    let activity: JsonElement
    let resultTransforms: [RSRPResultTransform]?
    
    init(identifier: String,
         activity: JsonElement,
         resultTransforms: [RSRPResultTransform]?) {
        
        self.identifier = identifier
        self.activity = activity
        self.resultTransforms = resultTransforms
    }

}
