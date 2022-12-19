//
//  WatchShaker.swift
//  WatchShaker
//
//  Created by Ezequiel on 09/12/16.
//  Copyright © 2016 Ezequiel França @ezefranca. All rights reserved.
//
import Foundation
import CoreMotion

///  WatchShaker
///
///  Discussion:
///  - The WatchShaker object is your entry point to the shake service.
public class WatchShaker : NSObject
{
    public var delegate: WatchShakerDelegate?
    public var startWatchShakerUpdates: WatchShakerHandler?
    public private(set) var coordinates: ShakeCoordinates?
    
    @Published public var isShakerAvailable: Bool = false
    @Published public var shake: Shake = .init(sensibility: .shakeSensibilityNormal, direction: .shakeDirectionDown)
    
    fileprivate var motionManager: CMMotionManager!
    fileprivate var lastShakeDate: Date?
    
    // The threshold for how much acceleration needs to happen before an event will register.
    fileprivate var threshold:Double
    fileprivate var sensibility:ShakeSensibility
    // Time between shakes
    fileprivate var delay:Double = 0.2
    
    /// Class init
    ///
    /// - Parameters:
    ///   - shakeThreshold: The threshold for how much acceleration needs to happen before an event will register.
    ///   - shakeDelay: Time between shakes
    
    public init(shakeSensibility to:ShakeSensibility, delay time:Double) {
        self.threshold = to.rawValue
        self.delay = time
        self.sensibility = to
        self.lastShakeDate = Date()
        self.motionManager = CMMotionManager()
        super.init()
        self.start()
    }
    
    /// start
    ///
    /// - Parameter accelerometerUpdateInterval: optional: (default is 0.02)
    public func start(delay accelerometerUpdateInterval:Double = 0.02)
    {
        guard motionManager.isAccelerometerAvailable else {
            debugPrint("isAccelerometerAvailable:   \(motionManager.isAccelerometerAvailable)")
            return
        }
        
        self.isShakerAvailable = motionManager.isAccelerometerAvailable
        
        if motionManager.isDeviceMotionAvailable {
            
            debugPrint("isDeviceMotionAvailable:  \(motionManager.isDeviceMotionAvailable)")
            debugPrint("isGyroAvailable:  \(motionManager.isGyroAvailable)")
            debugPrint("isAccelerometerAvailable:   \(motionManager.isAccelerometerAvailable)")
            debugPrint("isMagnetometerAvailable:   \(motionManager.isMagnetometerAvailable)")
            
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.showsDeviceMovementDisplay = true
            motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        }
        
        motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
        
        let motionQueue = OperationQueue()
        
        motionManager.startAccelerometerUpdates(to: motionQueue) { (accelerometerData, err) -> Void in
                        
            guard let data = accelerometerData, err == nil else
            {
                let e = NSError(domain: "No accelerometer data", code: 666, userInfo: ["No accelerometer data":"info"])
                self.delegate?.watchShaker(self, didFailWith: err ?? e)
                self.startWatchShakerUpdates?(nil, nil, err ?? e)
                return
            }
            
            let valueX = data.acceleration.x
            let valueY = data.acceleration.y
            let valueZ = data.acceleration.z
            
            self.coordinates = ShakeCoordinates(x: valueX, y: valueY, z: valueZ)
            
            let maxValue = fabs(valueX) > fabs(valueY) ? fabs(valueX) : fabs(valueY)
            
            if let lastDate = self.lastShakeDate, maxValue > self.threshold, self.compare(lastDate) {
            
                self.lastShakeDate = Date()
                self.didShake()
            }
        }
    }
    
    /// stop
    ///
    ///
    public func stop()
    {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func compare(_ date: Date) -> Bool {
        return Date().compare(date.addingTimeInterval(self.delay)) == .orderedDescending
    }
    
    private func didShake() {
        self.delegate?.watchShaker(self,
                                   didShakeWith: sensibility,
                                   direction: .direction(coordinates?.x ?? 0, coordinates?.y ?? 0))
        
        self.shake = .init(sensibility: sensibility,
                           direction: .direction(coordinates?.x ?? 0, coordinates?.y ?? 0))
        self.startWatchShakerUpdates?(self.sensibility, self.coordinates, nil)
    }
}

extension WatchShaker  {
    
    /// Threshold
    ///
    /// - Parameter sensibility: set new threshold sensibility
    public func threshold(new sensibility:ShakeSensibility) {
        self.threshold = sensibility.rawValue
    }
    
    /// Delay
    ///
    /// - Parameter value: set a new delay value
    public func delay(value:Double) {
        self.delay = value
    }
}

