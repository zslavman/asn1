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
	private let allNames = ["func1", "Очист.", "Кн.1", "Кн.2", "Сенсор"]
	let temp = "ijhsdjahfgkjhskjfhjkshjkhsdkjfhkjsdhfjlhsljhflsjkhjljskhfjdshfjshfjkshfjkhsf jhs jfhsjfh jsh fjhflkwe fngerkljgjn ianhti erpkrol ijhsdjahfgk jhskjfhjkshjkhsdkjfhkj sdhfjlhsljhflsjkhjljskhfjdshfjshfjkshfjkhsf jhs jfhsjfh jsh fjhjg kjoghj,cbk ixfjkjdfnrj gfr" // 256 bytes
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
		//textView.text = temp
		ProximityService.shared.textView = textView
	}
	
	
	private func configure() {
		navigationItem.title = "Test ANS1"
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
		guard let str = textView.text, str != "" else { return }
		let data = str.data(using: .utf8)!
		let keys = Cipher.generatePair_RSA(type: .accountKey)!
		if let decrypted = Cipher.encrypt_RSA(data: data, rsaPublicKeyData: keys.publicDataKey) {
			textLabel.text = "\(decrypted)"
			textView.text = decrypted.base64EncodedString()
		}
		UIPasteboard.general.string = textView.text
	}
	
	
	@IBAction func onBttn2Click(_ sender: UIButton) {
		let keys = Cipher.generatePair_RSA(type: .accountKey)!
		let keyWithAddedHeader = Cipher.addHeaderForPubKey(keys.publicDataKey)
		let str = keyWithAddedHeader.base64EncodedString()
		textView.text = str
		textLabel.text = "\(keyWithAddedHeader)"
		UIPasteboard.general.string = textView.text
	}
	

	@IBAction func onBttn3Click(_ sender: UIButton) {
		let service = ProximityService.shared
		service.activateProximitySensor(status: !service.proximStatus)
		if service.proximStatus {
			bttn3.backgroundColor = #colorLiteral(red: 0.7067964162, green: 0.2274190785, blue: 0.2195867891, alpha: 1)
			bttn3.setTitle("Отключить", for: .normal)
		}
		else {
			bttn3.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.3254901961, blue: 0.5490196078, alpha: 1)
			bttn3.setTitle("Сенсор", for: .normal)
		}
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
		textView.resignFirstResponder()
	}
	
	// -------------------------------------
	


}

