//
//  OhmageExtensibleStateManager.swift
//  ResearchSuiteAppFramework
//
//  Created by James Kizer on 3/28/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ResearchSuiteAppFramework
import OhmageOMHSDK
import ReSwift

open class OhmageExtensibleStateManager: RSAFExtensibleStateManager, CTFOhmageSDKInjector {
    
    let ohmageManagerClosure: (() -> OhmageOMHManager?)?
    
    public init(store: Store<RSAFCombinedState>, ohmageManagerClosure: (() -> OhmageOMHManager?)? = nil) {
        self.ohmageManagerClosure = ohmageManagerClosure
        super.init(store: store)
    }
    
    public func getOhmageManager() -> OhmageOMHManager? {
        return self.ohmageManagerClosure?()
    }

}
