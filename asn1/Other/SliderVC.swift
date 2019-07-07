//
//  SliderVC.swift
//  asn1
//
//  Created by Zinko Viacheslav on 07.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import MediaPlayer

class SliderVC: UIViewController {
	
	private let customSlider: InfoSlider = {
		let slid = InfoSlider()
		return slid
	}()
	private let kvoSoundVolumeKey1 = "AVSystemController_SystemVolumeDidChangeNotification"
	private let kvoSoundVolumeKey2 = "AVSystemController_AudioVolumeChangeReasonNotificationParameter"

	
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .white
		installSlider()
		customSlider.addTarget(self, action: #selector(onSliderChange), for: .valueChanged)
		try? AVAudioSession.sharedInstance().setActive(true)
		AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: [.new], context: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(notif:)),
											   name: NSNotification.Name(rawValue: kvoSoundVolumeKey1), object: nil)
    }
	

	private func installSlider() {
		view.addSubview(customSlider)
		NSLayoutConstraint.activate([
			customSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			NSLayoutConstraint(item: customSlider,
							   attribute: .centerY,
							   relatedBy: .equal,
							   toItem: view,
							   attribute: .centerY,
							   multiplier: 1.3,
							   constant: 0),
			customSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85, constant: 0),
		])
	}
	
	
	@objc private func onSliderChange(sender: UISlider) {
		//print("valueChanged = \(sender.value)")
	}
	
	
	/// volume buttons handlerd (limit is reached)
	@objc private func volumeChanged(notif: Notification) {
		print(11111)
		guard let userInfo = notif.userInfo else { return }
		guard let volumeChangeType = userInfo[kvoSoundVolumeKey2] as? String else { return }
		guard volumeChangeType == "ExplicitVolumeChange" else { return }
		let curSysVolume = AVAudioSession.sharedInstance().outputVolume

		customSlider.setValue(curSysVolume, animated: true)
	}
	
	
	/// volume buttons handlerd (limit not reached)
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let key = keyPath, let change = change else { return }
		if key == "outputVolume" {
			let newValue = change[.newKey] as! NSNumber
			customSlider.setValue(newValue.floatValue, animated: true)
		}
	}
	
	
	deinit {
//		try? AVAudioSession.sharedInstance().setActive(false)
//		NotificationCenter.default.removeObserver(self)
	}

}