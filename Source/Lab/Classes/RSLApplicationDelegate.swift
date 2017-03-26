//
//  RSLApplicationDelegate.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit

open class RSLApplicationDelegate: RSAFApplicationDelegate {

    override open func instantiateOnboardingViewController() -> UIViewController? {
        let bundle = Bundle(for: RSLApplicationDelegate.self)
        
        guard let url = bundle.url(forResource: "LabResources", withExtension: "bundle"),
            let resourceBundle = Bundle(url: url) else {
            return nil
        }
        let mainStoryboard = UIStoryboard(name: "RSLOnboarding", bundle: resourceBundle)
        return mainStoryboard.instantiateViewController(withIdentifier: "onboarding")
    }
    
    
    
    open func signInItem() -> RSAFScheduleItem? {
        return nil
    }
    
    open func researcherDemographics() -> RSAFScheduleItem? {
        return nil
    }
    
    open func participantDemographics() -> RSAFScheduleItem? {
        return nil
    }
    
    open func participantSchedule() -> RSAFSchedule? {
        return nil
    }
    
    
}
