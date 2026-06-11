//
//  GlobalDefinitions.swift
//  Nursing
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let domain = "https://bank4.thinkaboutapps.com"
    static let apiKey = "GS3Fx34F3dxuy2LM"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "0y60LRzLDu7qCzj9"
    
    static let termsOfServiceUrl = URL(string: "https://thinkaboutapps.com/terms")!
    static let privacyPolicyUrl = URL(string: "https://thinkaboutapps.com/policy")!
    static let contactUsUrl = URL(string: "https://thinkaboutapps.com/contact")!
    
    enum Paygate {
        static let lifetime = "prep.exams.cdl.lifetime"
        static let subscription = "prep.exams.cdl.monthly.nottrial"
    }
}
