//
//  ProximityService.swift
//  asn1
//
//  Created by Zinko Viacheslav on 23.04.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


class ProximityService {
	
	public static let shared = ProximityService()
	public var textView: UITextView!
	
	public var proximStatus: Bool {
		return UIDevice.current.isProximityMonitoringEnabled
	}
	
	
	public func activateProximitySensor(status: Bool) {
		let device = UIDevice.current
		device.isProximityMonitoringEnabled = status
		if status {
			NotificationCenter.default.addObserver(self, selector: #selector(proximityStateDidChange), name: UIDevice.proximityStateDidChangeNotification, object: device)
		}
		else {
			NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: device)
		}
	}
	
	
	@objc private func proximityStateDidChange(notification: NSNotification) {
		guard let device = notification.object as? UIDevice else { return }
		
		let eventData = SUtils.convertDate(date: Date())
		var str = ""
		
		if device.proximityState {
			str = "\(eventData) - приближение"
		}
		else {
			str = "\(eventData) - отдаление"
		}
		textView.text += "\n  \(str)"
	}
	
	
}
