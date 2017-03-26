//
//  AppDelegate.swift
//  ResearchSuiteAppFramework
//
//  Created by jdkizer9 on 03/22/2017.
//  Copyright (c) 2017 jdkizer9. All rights reserved.
//

import UIKit
import ResearchSuiteAppFramework
import OhmageOMHSDK

@UIApplicationMain
final class AppDelegate: RSLApplicationDelegate {
    
    var ohmageManager: OhmageOMHManager!

    open override func loadCombinedReducer() -> RSAFCombinedReducer {
        return RSAFCombinedReducer(
            coreReducer: RSAFCoreReducer(),
            middlewareReducer: RSAFBaseReducer(),
            appReducer: RSAFBaseReducer()
        )
    }
    
    func initializeOhmage() -> OhmageOMHManager {
        
        guard let store = self.reduxStore,
            let file = Bundle.main.path(forResource: "OMHClient", ofType: "plist") else {
                fatalError("Could not initialze OhmageManager")
        }
        
        let omhClientDetails = NSDictionary(contentsOfFile: file)
        
        guard let baseURL = omhClientDetails?["OMHBaseURL"] as? String,
            let clientID = omhClientDetails?["OMHClientID"] as? String,
            let clientSecret = omhClientDetails?["OMHClientSecret"] as? String else {
                fatalError("Could not initialze OhmageManager")
        }
        
        let credentialsStore = OhmageCredentialsStore(store: store)
        
        if OhmageOMHManager.config(baseURL: baseURL,
                                   clientID: clientID,
                                   clientSecret: clientSecret,
                                   queueStorageDirectory: "ohmageSDK",
                                   store: credentialsStore) {
            return OhmageOMHManager.shared
        }
        else {
            fatalError("Could not initialze OhmageManager")
        }
        
    }
    
    open override func initializeState() {
        
        super.initializeState()
        
        self.ohmageManager = self.initializeOhmage()
        
    }
    
    open override func signOut() {
        self.ohmageManager.signOut { (error) in
            super.signOut()
        }
    }
    
    open override func isSignedIn(state: RSAFCombinedState) -> Bool {
        return self.ohmageManager.isSignedIn
    }

}

