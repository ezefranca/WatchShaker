//
//  WatchShakerDelegate.swift
//  
//
//  Created by Ezequiel França on 09/04/21.
//

/// @protocol WatchShakerDelegate
///
/// Discussion
/// - Delegate for WatchShaker.
public protocol WatchShakerDelegate
{
    /// Called when Apple Watch are shaked
    ///
    /// - Parameter watchShaker: the watch shaker instance
    func watchShaker(_ watchShaker: WatchShaker, didShakeWith sensibility:ShakeSensibility, direction:ShakeDirection)
    
    /// Called when Something are wrong
    ///
    /// - Parameter watchShaker: the watch shaker instance
    /// - Parameter error: error ocurred
    func watchShaker(_ watchShaker:WatchShaker, didFailWith error: Error)
}

extension WatchShakerDelegate {
    func watchShaker(_ watchShaker: WatchShaker, didShakeWith sensibility:ShakeSensibility, direction:ShakeDirection) {
        self.watchShaker(watchShaker, didShakeWith: sensibility, direction: .shakeDirectionUnknow)
    }
}
