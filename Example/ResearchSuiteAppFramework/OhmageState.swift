//
//  OhmageState.swift
//  ResearchSuiteAppFramework
//
//  Created by James Kizer on 3/25/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ReSwift
import ResearchSuiteAppFramework

final public class OhmageOMHSSDKState: RSAFBaseState {
    
    let sessionToken: String?
    let email: String?
    let password: String?
    
    public required init() {
        self.sessionToken = nil
        self.email = nil
        self.password = nil
        super.init()
    }
    
    public init(sessionToken: String?, email: String?, password: String?) {
        self.sessionToken = sessionToken
        self.email = email
        self.password = password
        super.init()
    }
    
    public static func newState(
        fromState: OhmageOMHSSDKState,
        sessionToken: (String?)? = nil,
        email: (String?)? = nil,
        password: (String?)? = nil
        ) -> OhmageOMHSSDKState {
        return OhmageOMHSSDKState(
            sessionToken: sessionToken ?? fromState.sessionToken,
            email: email ?? fromState.email,
            password: password ?? fromState.password
        )
    }

}
