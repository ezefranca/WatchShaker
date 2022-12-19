//
//  ShakeSensibility.swift
//  
//
//  Created by Ezequiel França on 09/04/21.
//
#if os(watchOS)
/// ShakeSensibility
///
/// - shakeSensibilitySoftest: Softest shake sensibility
/// - shakeSensibilitySoft: Soft shake sensibility
/// - shakeSensibilityNormal: Normal shake sensibility
/// - shakeSensibilityHard: Hard shake sensibility
/// - shakeSensibilityHardest: Hardest shake sensibility
public enum ShakeSensibility: Double {
    public typealias RawValue = Double
    case shakeSensibilitySoftest = 0.1
    case shakeSensibilitySoft = 0.7
    case shakeSensibilityNormal = 1.0
    case shakeSensibilityHard = 1.2
    case shakeSensibilityHardest = 2.0
}
#endif
