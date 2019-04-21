//
//  ViewController.swift
//  asn1
//
//  Created by Zinko Viacheslav on 17.04.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var textLabel: UITextView!
	@IBOutlet weak var bttn1: UIButton!
	@IBOutlet weak var bttn2: UIButton!
	@IBOutlet weak var bttn3: UIButton!
	@IBOutlet weak var bttnNavLeft: UIBarButtonItem!
	@IBOutlet weak var bttnNavRight: UIBarButtonItem!
	private lazy var allBttns = [bttnNavLeft, bttnNavRight, bttn1, bttn2, bttn3]
	private let allNames = ["Лев", "Очист.", "Кн.1", "Кн.2", "Кн.3"]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
	}
	
	
	private func configure() {
		navigationItem.title = "Test ANS1 data"
		textView.layer.cornerRadius = 8
		textLabel.layer.cornerRadius = 8
		for (index, item) in allBttns.enumerated() {
			if let bttn = item as? UIButton {
				bttn.setTitle(allNames[index], for: .normal)
				bttn.layer.cornerRadius = 6
			}
			else if let navBttn = item as? UIBarButtonItem {
				navBttn.title = allNames[index]
			}
		}
	}
	
	
	@IBAction func onBttn1Click(_ sender: UIButton) {
		let keys = Cipher.generatePair_RSA(type: .accountKey)!
		let keyWithAddedHeader = Cipher.addHeaderForPrivateKey(keys.publicDataKey)
		let str = keyWithAddedHeader.base64EncodedString()
		textView.text = str
		textLabel.text = "\(keyWithAddedHeader)"
		UIPasteboard.general.string = textView.text
	}
	
	
	@IBAction func onBttn2Click(_ sender: UIButton) {
		let keys = Cipher.generatePair_RSA(type: .accountKey)!
		let keyWithAddedHeader = Cipher.addHeaderForPrivateKey(keys.privateDataKey)
		let str = keyWithAddedHeader.base64EncodedString()
		textView.text = str
		textLabel.text = "\(keyWithAddedHeader)"
		UIPasteboard.general.string = textView.text
	}
	
	@IBAction func onBttn3Click(_ sender: UIButton) {
		let keys = Cipher.generatePair_RSA(type: .accountKey)!
		let str = keys.privateDataKey.base64EncodedString()
		textView.text = str
		textLabel.text = "\(keys.privateDataKey)"
		UIPasteboard.general.string = textView.text
	}
	
	@IBAction func onbttnNavLeft(_ sender: Any) {
		guard let str = textView.text, str != "" else { return }
		guard let number = Int(str) else { return }
		textLabel.text = ""
		let bytesArr = Cipher.splitToOctets(number)
		bytesArr.forEach{textLabel.text += "\(String($0, radix: 16)) \n"}
	}

	@IBAction func onbttnNavRight(_ sender: Any) {
		textView.text = ""
		textLabel.text = ""
	}
	
	

}

