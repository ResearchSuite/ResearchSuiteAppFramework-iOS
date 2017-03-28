//
//  RSAFSelectors.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ResearchKit

public class RSAFCoreSelectors: NSObject {
    
    public static func isLoggedIn(_ state: RSAFCoreState) -> Bool {
        //coreState MUST be RSAFCoreState
        return state.loggedIn
    }
    
    public static func getExtensibleStorage(_ state: RSAFCoreState) -> [String : NSObject] {
        return state.extensibleStorage
    }
    
    public static func getValueInExtensibleStorage(_ state: RSAFCoreState) -> (String) -> NSSecureCoding? {
        return { key in
            return state.extensibleStorage[key] as? NSSecureCoding
        }
    }
    
    public static func getResultsQueue(_ state: RSAFCoreState) -> [(UUID, RSAFActivityRun, ORKTaskResult)] {
        return state.resultsQueue
    }
    

}
