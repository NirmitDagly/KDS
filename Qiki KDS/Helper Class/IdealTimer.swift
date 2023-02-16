//
//  IdealTimer.swift
//  Qiki Cusine
//
//  Created by Miamedia Developer on 22/4/21.
//

import Foundation
import UIKit

class IdealTimer: UIApplication {
    //The timeout in seconds for when to fire the idle timer.
    let timeoutInSeconds: TimeInterval = 1 * 60
    
    var idleTimer: Timer?

    //Resent the timer because there was user interaction.
    func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds, target: self, selector: #selector(IdealTimer.idleTimerExceeded), userInfo: nil, repeats: false)
    }

    //If the timer reaches the limit as defined in timeoutInSeconds, post this notification.
    @objc func idleTimerExceeded() {
        NotificationCenter.default.post(name: .applicationDidTimoutNotification, object: nil)
    }

    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        if event.allTouches?.contains(where: { $0.phase == .began || $0.phase == .moved }) == true {
            resetIdleTimer()
        }
    }
}
