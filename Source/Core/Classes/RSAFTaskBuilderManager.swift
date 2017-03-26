//
//  RSAFTaskBuilderManager.swift
//  Pods
//
//  Created by James Kizer on 3/25/17.
//
//

import UIKit
import ResearchSuiteTaskBuilder

open class RSAFTaskBuilderManager: NSObject {
    
    
    open class func stepGeneratorServices() -> [RSTBStepGenerator] {
        return [
            RSTBInstructionStepGenerator(),
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBFormStepGenerator(),
            RSTBDatePickerStepGenerator()
        ]
    }
    
    open class func answerFormatGeneratorServices() -> [RSTBAnswerFormatGenerator] {
        return [
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBDatePickerStepGenerator()
        ]
    }

    open class func elementGeneratorServices() -> [RSTBElementGenerator] {
        return [
            RSTBElementListGenerator(),
            RSTBElementFileGenerator(),
            RSTBElementSelectorGenerator()
        ]
    }
    
    let rstb: RSTBTaskBuilder
    
    init(stateHelper: RSTBStateHelper) {
        
        // Do any additional setup after loading the view, typically from a nib.
        self.rstb = RSTBTaskBuilder(
            stateHelper: stateHelper,
            elementGeneratorServices: RSAFTaskBuilderManager.elementGeneratorServices(),
            stepGeneratorServices: RSAFTaskBuilderManager.stepGeneratorServices(),
            answerFormatGeneratorServices: RSAFTaskBuilderManager.answerFormatGeneratorServices())
        
        super.init()
        
        
    }
    
    static func getJson(forFilename filename: String, inBundle bundle: Bundle = Bundle.main) -> JsonElement? {
        
        guard let filePath = bundle.path(forResource: filename, ofType: "json")
            else {
                assertionFailure("unable to locate file \(filename)")
                return nil
        }
        
        guard let fileContent = try? Data(contentsOf: URL(fileURLWithPath: filePath))
            else {
                assertionFailure("Unable to create NSData with content of file \(filePath)")
                return nil
        }
        
        let json = try! JSONSerialization.jsonObject(with: fileContent, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        return json as JsonElement?
    }

}
