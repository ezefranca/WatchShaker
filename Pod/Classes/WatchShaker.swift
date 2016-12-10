//
//  WatchShaker.swift
//  WatchShaker
//
//  Created by Ezequiel on 09/12/16.
//  Copyright © 2016 Ezequiel França @ezefranca. All rights reserved.
//

import Foundation
import CoreMotion


/// ShakeSensibility
///
/// - shakeSensibilitySoftest: Softest shake sensibility
/// - shakeSensibilitySoft: Soft shake sensibility
/// - shakeSensibilityNormal: ormal shake sensibility
/// - shakeSensibilityHard: Hard shake sensibility
/// - shakeSensibilityHardest: Hardest shake sensibility

enum ShakeSensibility: Double {
    case shakeSensibilitySoftest = 0.1
    case shakeSensibilitySoft = 0.7
    case shakeSensibilityNormal = 1.0
    case shakeSensibilityHard = 1.2
    case shakeSensibilityHardest = 2.0
}

protocol WatchShakerDelegate
{
    
    /// Called when Apple Watch are shaked
    func didShake()
    
    /// Called when Something are wrong
    ///
    /// - Parameter error: error ocurred
    func error(with error: Error)
}

extension WatchShaker  {
    
    /// threshold
    ///
    /// - Parameter sensibility: set new threshold sensibility
    public func threshold(new sensibility:ShakeSensibility) {
        self.threshold = sensibility.rawValue
    }
    
    /// delay
    ///
    /// - Parameter value: set a new delay value
    public func delay(value:Double) {
        self.delay = value
    }
}


class WatchShaker
{
    public var delegate: WatchShakerDelegate?
    
    fileprivate var motionManager: CMMotionManager!
    fileprivate var lastShakeDate: Date?
    // The threshold for how much acceleration needs to happen before an event will register.
    fileprivate var threshold:Double
    // Time between shakes
    fileprivate var delay:Double = 0.1
    
    /// Class init
    ///
    /// - Parameters:
    ///   - shakeThreshold: The threshold for how much acceleration needs to happen before an event will register.
    ///   - shakeDelay: Time between shakes
    
    init(shakeSensibility to:ShakeSensibility, delay time:Double) {
        self.threshold = to.rawValue
        self.delay = time
        self.motionManager = CMMotionManager()
    }
    
    /// start
    ///
    /// - Parameter accelerometerUpdateInterval: optional: (default is 0.02)
    public func start(delay accelerometerUpdateInterval:Double = 0.02)
    {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
        
        let motionQueue = OperationQueue()
        
        motionManager.startAccelerometerUpdates(to: motionQueue) { (accelerometerData, err) -> Void in
            
            guard err == nil else
            {
                self.delegate?.error(with: err!)
                return
            }
            
            guard let data = accelerometerData else
            {
                let e = NSError(domain: "No accelerometer data", code: 666, userInfo: ["No accelerometer data":"info"])
                self.delegate?.error(with: e)
                return
            }
            
            let valueX = fabs(data.acceleration.x)
            let valueY = fabs(data.acceleration.y)
            let maxValue = valueX > valueY ? valueX : valueY
            
            if maxValue > self.threshold
            {
                if let lastDate = self.lastShakeDate
                {
                    if Date().compare(lastDate.addingTimeInterval(self.delay)) == .orderedDescending
                    {
                        self.lastShakeDate = Date()
                        self.delegate?.didShake()
                    }
                    return
                }
                
                self.lastShakeDate = Date()
                self.delegate?.didShake()
            }
        }
    }
    
    func stop()
    {
        motionManager.stopAccelerometerUpdates()
    }
}
