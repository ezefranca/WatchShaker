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
    
    @IBOutlet var infoLabel: WKInterfaceLabel!
    override func willActivate() {
        
        super.willActivate()
        shaker.delegate = self
        shaker.start()
    }
    
    override func didDeactivate() {
        
        super.didDeactivate()
        shaker.stop()
        
    }
    
    func printInfo(_ string:String) {
        self.infoLabel.setText(string)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.infoLabel.setText("")
        }
    }
    
}

extension InterfaceController: WatchShakerDelegate
{
    func watchShaker(_ watchShaker: WatchShaker, didShakeWith sensibility: ShakeSensibility) {
        let message = "YOU HAVE SHAKEN YOUR ⌚️⌚️⌚️"
        print(message)
        printInfo(message)
        
    }

    func watchShaker(_ watchShaker: WatchShaker, didFailWith error: Error) {
        print(error.localizedDescription)
        printInfo(error.localizedDescription)
    }
}
