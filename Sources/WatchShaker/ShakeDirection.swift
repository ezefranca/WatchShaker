//
//  ShakeDirection.swift
//  
//
//  Created by Ezequiel França on 09/04/21.
//

/// ShakeDirection
///
/// - shakeDirectionUp: y variation < 0 (Rotate your arm up to the Watch)
///
/// - shakeDirectionDown: y variation > 0 (Rotate your arm down to the Watch)
///
/// - shakeDirectionRight: x variation > 0 (Like a punch front to you)
///
/// - shakeDirectionLeft: x variation < 0 (Like a pull a door to you)
///
/// - shakeDirectionUnknow: When it's not possible to determine

import Foundation

#if os(watchOS)
public enum ShakeDirection {
    
    case shakeDirectionUp
    case shakeDirectionDown
    case shakeDirectionLeft
    case shakeDirectionRight
    case shakeDirectionUnknow
    
    static func direction(_ x: Double, _ y: Double) -> ShakeDirection {
        
        let valueX = fabs(x)
        let valueY = fabs(y)
     
        if valueX > valueY, x > 0 {
            return ShakeDirection.shakeDirectionRight
        }
        
        if valueX > valueY, x < 0 {
            return ShakeDirection.shakeDirectionLeft
        }
        
        if valueX < valueY, y > 0 {
            return ShakeDirection.shakeDirectionDown
        }
        
        if valueX < valueY, y < 0 {
            return ShakeDirection.shakeDirectionUp
        }
        
        return ShakeDirection.shakeDirectionUnknow
    }
}
#endif
