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
    public let sessionTaskBuilder: RSAFTaskBuilderManager?
    public let sessionResultsProcessor: RSAFResultsProcessorManager?
    
    public init(researcherDemographicsCompleted: Bool = false,
                sessionId: String? = nil,
                sessionStorage: [String: NSObject] = [:],
                sessionTaskBuilder: RSAFTaskBuilderManager? = nil,
                sessionResultsProcessor: RSAFResultsProcessorManager? = nil
        ) {
        
        self.researcherDemographicsCompleted = researcherDemographicsCompleted
        self.sessionId = sessionId
        self.sessionStorage = sessionStorage
        self.sessionTaskBuilder = sessionTaskBuilder
        self.sessionResultsProcessor = sessionResultsProcessor
        
        super.init()
        
    }
    
    public required override convenience init() {
        self.init(researcherDemographicsCompleted: false)
    }
    
    
    static func newState(
        fromState: RSLLabState,
        researcherDemographicsCompleted: Bool? = nil,
        sessionId: String?? = nil,
        sessionStorage: [String: NSObject]? = nil,
        sessionTaskBuilder: RSAFTaskBuilderManager?? = nil,
        sessionResultsProcessor: RSAFResultsProcessorManager?? = nil
        ) -> RSLLabState {
        
        return RSLLabState(
            researcherDemographicsCompleted: researcherDemographicsCompleted ?? fromState.researcherDemographicsCompleted,
            sessionId: sessionId ?? fromState.sessionId,
            sessionStorage: sessionStorage ?? fromState.sessionStorage,
            sessionTaskBuilder: sessionTaskBuilder ?? fromState.sessionTaskBuilder,
            sessionResultsProcessor: sessionResultsProcessor ?? fromState.sessionResultsProcessor
        )
    }
    
    open override var description: String {
        return "\n\tsessionId: \(self.sessionId)\n\tsessionStorage: \(self.sessionStorage)"
    }

}
