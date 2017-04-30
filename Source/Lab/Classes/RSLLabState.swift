//
//  RSLLabState.swift
//  Pods
//
//  Created by James Kizer on 3/27/17.
//
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchSuiteTaskBuilder

public final class RSLLabState: RSAFBaseState {
    
    public let researcherDemographicsCompleted: Bool
    public let sessionId: String?
    public let sessionLabel: String?
    public let sessionStorage: [String: NSObject]
    public let sessionTaskBuilder: RSTBTaskBuilder?
    public let sessionResultsProcessor: RSRPResultsProcessor?
    
    public init(researcherDemographicsCompleted: Bool = false,
                sessionId: String? = nil,
                sessionLabel: String? = nil,
                sessionStorage: [String: NSObject] = [:],
                sessionTaskBuilder: RSTBTaskBuilder? = nil,
                sessionResultsProcessor: RSRPResultsProcessor? = nil
        ) {
        
        self.researcherDemographicsCompleted = researcherDemographicsCompleted
        self.sessionId = sessionId
        self.sessionLabel = sessionLabel
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
        sessionLabel: String?? = nil,
        sessionStorage: [String: NSObject]? = nil,
        sessionTaskBuilder: RSTBTaskBuilder?? = nil,
        sessionResultsProcessor: RSRPResultsProcessor?? = nil
        ) -> RSLLabState {
        
        return RSLLabState(
            researcherDemographicsCompleted: researcherDemographicsCompleted ?? fromState.researcherDemographicsCompleted,
            sessionId: sessionId ?? fromState.sessionId,
            sessionLabel: sessionLabel ?? fromState.sessionLabel,
            sessionStorage: sessionStorage ?? fromState.sessionStorage,
            sessionTaskBuilder: sessionTaskBuilder ?? fromState.sessionTaskBuilder,
            sessionResultsProcessor: sessionResultsProcessor ?? fromState.sessionResultsProcessor
        )
    }
    
    open override var description: String {
        return "\n\tsessionId: \(self.sessionId)\n\tsessionLabel: \(self.sessionLabel)\n\tsessionStorage: \(self.sessionStorage)\nsessionTaskBuilder: \(self.sessionTaskBuilder)\nsessionResultsProcessor: \(self.sessionResultsProcessor)"
    }

}
