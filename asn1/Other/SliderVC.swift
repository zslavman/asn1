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

	
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .white
		installSlider()
		customSlider.addTarget(self, action: #selector(onSliderChange), for: .valueChanged)
		try? AVAudioSession.sharedInstance().setActive(true)
		AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: [.new], context: nil)
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
	

	/// volume buttons handlerd (if limits not reached)
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let key = keyPath, let change = change else { return }
		if key == "outputVolume" {
			let newValue = change[.newKey] as! NSNumber
			customSlider.setValue(newValue.floatValue, animated: false)
		}
	}
	
	
	deinit {
		try? AVAudioSession.sharedInstance().setActive(false)
		AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
	}

}
