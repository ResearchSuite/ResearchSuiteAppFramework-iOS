//
//  RSAFAppTaskBuilderManager.swift
//  ResearchSuiteAppFramework
//
//  Created by James Kizer on 3/26/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ResearchSuiteAppFramework
import ResearchSuiteTaskBuilder
import OhmageOMHSDK
import sdlrkx

open class RSAFAppTaskBuilderManager: RSAFTaskBuilderManager {
    
    open override class var stepGeneratorServices: [RSTBStepGenerator] {
        return [
            CTFOhmageLoginStepGenerator(),
            CTFBARTStepGenerator(),
            CTFDelayDiscountingStepGenerator(),
            CTFGoNoGoStepGenerator()
        ] + super.stepGeneratorServices
    }
    
    convenience public init(stateHelper: RSTBStateHelper) {
        
        self.init(
            stateHelper: stateHelper,
            elementGeneratorServices: RSAFTaskBuilderManager.elementGeneratorServices,
            stepGeneratorServices: RSAFAppTaskBuilderManager.stepGeneratorServices,
            answerFormatGeneratorServices: RSAFTaskBuilderManager.answerFormatGeneratorServices
        )
        
    }
}
