//
//  RSLLabState.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import UIKit

public final class RSLLabState: RSAFBaseState {
    
    public let researcherDemographicsCompleted: Bool
    public let sessionId: String?
    public let sessionStorage: [String: NSObject]
    
    public init(researcherDemographicsCompleted: Bool = false,
                sessionId: String? = nil,
                sessionStorage: [String: NSObject] = [:]
        ) {
        
        self.researcherDemographicsCompleted = researcherDemographicsCompleted
        self.sessionId = sessionId
        self.sessionStorage = sessionStorage
        
        super.init()
        
    }
    
    public required override convenience init() {
        self.init(researcherDemographicsCompleted: false)
    }
    
    
    static func newState(
        fromState: RSLLabState,
        researcherDemographicsCompleted: Bool? = nil,
        sessionId: (String?)? = nil,
        sessionStorage: [String: NSObject]? = nil
        ) -> RSLLabState {
        
        return RSLLabState(
            researcherDemographicsCompleted: researcherDemographicsCompleted ?? fromState.researcherDemographicsCompleted,
            sessionId: sessionId ?? fromState.sessionId,
            sessionStorage: sessionStorage ?? fromState.sessionStorage
        )
    }

}
