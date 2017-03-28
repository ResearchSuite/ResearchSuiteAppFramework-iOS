//
//  RSAFReduxState.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ReSwift
import ResearchKit

public final class RSAFCoreState: RSAFBaseState {

    let loggedIn: Bool
    let activityQueue: [(UUID, RSAFActivityRun)]
    let resultsQueue: [(UUID, RSAFActivityRun, ORKTaskResult)]
    
    let extensibleStorage: [String: NSObject]
    
    public init(loggedIn: Bool = false,
        activityQueue: [(UUID, RSAFActivityRun)] = [],
        resultsQueue: [(UUID, RSAFActivityRun, ORKTaskResult)] = [],
        extensibleStorage: [String: NSObject] = [:] ) {
        
        self.loggedIn = loggedIn
        self.activityQueue = activityQueue
        self.resultsQueue = resultsQueue
        self.extensibleStorage = extensibleStorage
        
        super.init()
        
    }
    
    public required override convenience init() {
        self.init(loggedIn: false)
    }

    
    static func newState(
        fromState: RSAFCoreState,
        loggedIn: Bool? = nil,
        activityQueue: [(UUID, RSAFActivityRun)]? = nil,
        resultsQueue: [(UUID, RSAFActivityRun, ORKTaskResult)]? = nil,
        extensibleStorage: [String: NSObject]? = nil
        ) -> RSAFCoreState {
        
        return RSAFCoreState(
            loggedIn: loggedIn ?? fromState.loggedIn,
            activityQueue: activityQueue ?? fromState.activityQueue,
            resultsQueue: resultsQueue ?? fromState.resultsQueue,
            extensibleStorage: extensibleStorage ?? fromState.extensibleStorage
        )
    }
    
    open override var description: String {
        return "\n\tloggedIn: \(self.loggedIn)\n\tactivityQueue: \(self.activityQueue)\n\tresultsQueue: \(self.resultsQueue)\n\textensibleStorage: \(self.extensibleStorage)"
    }
    
}
