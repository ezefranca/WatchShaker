//
//  InterfaceController.swift
//  WatchShaker WatchKit Extension
//
//  Created by Ezequiel on 09/12/16.
//  Copyright © 2016 Ezequiel França @ezefranca. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    var shaker:WatchShaker = WatchShaker(shakeSensibility: .shakeSensibilityNormal, delay: 0.2)
    
    override func willActivate() {
        
        super.willActivate()
        shaker.delegate = self
        shaker.start()
    }
    
    override func didDeactivate() {
        
        super.didDeactivate()
        shaker.stop()
        
    }
    
}

extension InterfaceController: WatchShakerDelegate
{
    func watchShakerDidShake(_ watchShaker: WatchShaker) {
        print("YOU HAVE SHAKEN YOUR ⌚️⌚️⌚️")
    }

    func watchShaker(_ watchShaker: WatchShaker, didFailWith error: Error) {
        print(error.localizedDescription)
    }
}
