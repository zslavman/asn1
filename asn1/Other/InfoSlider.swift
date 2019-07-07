//
//  InfoSlider.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 07.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class InfoSlider: UISlider {
	
	public let infoLable: UILabel = {
		let label = UILabel()
		label.backgroundColor = .red
		label.text = "100"
		label.textAlignment = .center
		//label.translatesAutoresizingMaskIntoConstraints = false
		label.alpha = 0
		return label
	}()
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	private func setup() {
		translatesAutoresizingMaskIntoConstraints = false
		addSubview(infoLable)
	}
	
	
	private func getCurrentThumbRect() -> CGRect {
		let trackRect = self.trackRect(forBounds: bounds)
		let thumbR = thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
		return thumbR
	}
	
	
	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let touchPoint: CGPoint = touch.location(in: self)
		// Check if the knob is touched. Only in this case show the popup-view
		if getCurrentThumbRect().insetBy(dx: -12, dy: -12).contains(touchPoint) {
			positionAndUpdatePopupView()
			showPopupView(true)
		}
		return super.beginTracking(touch, with: event)
	}


	override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		// Update the popup view as slider knob is being moved
		positionAndUpdatePopupView()
		return super.continueTracking(touch, with: event)
	}

	
	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		// Fade out the popoup view
		showPopupView(false)
		super.endTracking(touch, with: event)
	}


	private func showPopupView(_ fadeIn: Bool) {
		UIView.animate(withDuration: 0.3) {
			if fadeIn {
				self.infoLable.alpha = 1.0
			}
			else {
				self.infoLable.alpha = 0.0
			}
		}
	}


	private func positionAndUpdatePopupView() {
		let _thumbRect = getCurrentThumbRect()
		let popupRect = _thumbRect.offsetBy(dx: 0, dy: -_thumbRect.size.height * 1.5)
		infoLable.frame = popupRect.insetBy(dx: -20, dy: -10)
		infoLable.text = String(Int(value * 100))
	}
	
}

