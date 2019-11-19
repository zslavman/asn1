//
//  ViewController.swift
//  asn1
//
//  Created by Zinko Viacheslav on 17.04.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import QuickLook
import CircleProgressView


class ViewController: UIViewController {
	
	@IBOutlet weak var imaga: UIImageView!
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var textLabel: UITextView!
	@IBOutlet weak var bttn1: UIButton!
	@IBOutlet weak var bttn2: UIButton!
	@IBOutlet weak var bttn3: UIButton!
	@IBOutlet weak var bttnNavLeft: UIBarButtonItem!
	@IBOutlet weak var bttnNavRight: UIBarButtonItem!
	private lazy var allBttns = [bttnNavLeft, bttnNavRight, bttn1, bttn2, bttn3]
	private let allNames = ["func1", "Очист.", "Кн.1", "Кн.2", "Сенсор"]
	let temp = "so @Emmanuel is there any way for it to use the attributes on the attributedText?"
	let temp2 = "so @Emmanuel"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
		ProximityService.shared.textView = textView
		doRoundedRectOnText()
//		imaga.image = #imageLiteral(resourceName: "Steven-Deutsch")
//		imaga.contentMode = .scaleAspectFill
//		imaga.layer.masksToBounds = true
		
		//installProgressBar()
	}
	
	private func doRoundedRectOnText() {
		let roundedTextView = HighlightLabel()
		roundedTextView.translatesAutoresizingMaskIntoConstraints = false
		roundedTextView.layer.borderWidth = 1
		roundedTextView.layer.borderColor = UIColor.black.cgColor
		
		
		let atr = NSAttributedString(string: temp2, attributes: [
			NSAttributedString.Key.foregroundColor	: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1),
			NSAttributedString.Key.font				: UIFont.systemFont(ofSize: 30, weight: .regular),
			NSAttributedString.Key(rawValue: "MyRoundedBackgroundColor"): #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
		])
		
		roundedTextView.configWith(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), atribute: atr)
		//roundedTextView.attributedText = atr
		view.addSubview(roundedTextView)
		NSLayoutConstraint.activate([
			roundedTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			roundedTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			roundedTextView.widthAnchor.constraint(equalToConstant: 300),
			roundedTextView.heightAnchor.constraint(equalToConstant: 250),
		])
	}
	
	
	
	var progressView: CircleProgressView = {
		let progressView = CircleProgressView(frame: .zero)
		progressView.translatesAutoresizingMaskIntoConstraints = false
		progressView.trackWidth = 2
		progressView.trackBorderWidth = 2
		progressView.trackFillColor = .white
		progressView.roundedCap = true
		progressView.trackBackgroundColor = .clear
		progressView.centerFillColor = .clear
		progressView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		progressView.layer.cornerRadius = 18
		progressView.layer.masksToBounds = true
		//progressView.centerImage = ViewController.resizeImage(#imageLiteral(resourceName: "close_upload"), firstOutSide: 12, isMin: true)
		return progressView
	}()
	
	private func installProgressBar() {
		view.addSubview(progressView)
		
		NSLayoutConstraint.activate([
			progressView.widthAnchor.constraint(equalToConstant: 36),
			progressView.heightAnchor.constraint(equalToConstant: 36),
			progressView.centerXAnchor.constraint(equalTo: textView.centerXAnchor),
			progressView.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
		])
		progressView.progress = 0.33
		
		let chrost = UIImageView(image: #imageLiteral(resourceName: "close_upload"))
		chrost.translatesAutoresizingMaskIntoConstraints = false
		chrost.contentMode = .scaleAspectFit
		//view.addSubview(chrost)
		progressView.addSubview(chrost)
		
		NSLayoutConstraint.activate([
			chrost.widthAnchor.constraint(equalToConstant: 24),
			chrost.heightAnchor.constraint(equalToConstant: 24),
			chrost.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
			chrost.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
		])
		
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
	
	
	let orientations = ["f1t", "f2t", "f3t", "f4t", "f5t", "f6t","f7t", "f8t"]
	var count: Int = 0
	
	@IBAction func onBttn1Click(_ sender: UIButton) {
//		imaga.contentMode = .scaleAspectFit
//		let imName = orientations[count] + ".jpg"
//		imaga.image = UIImage(named: imName)
//		count += 1
//		if count > orientations.count - 1 {
//			count = 0
//		}
		
		/// for MessageKit
		let vc = LaunchViewController()
		navigationController?.pushViewController(vc, animated: true)
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
	
	
	
	
	/// Resize image proportionally
	///
	/// - Parameters:
	///   - image: source
	///   - firstOutSide: required size of the output side
	///   - isMin: if true - firstOutSide will be min, else - max
	public static func resizeImage(_ image: UIImage, firstOutSide: CGFloat, isMin: Bool) -> UIImage {
		let size = image.size
		let isLandscape = size.width > size.height
		let origMinSide = min(size.width, size.height)
		let origMaxSide = max(size.width, size.height)
		let ratio = origMaxSide / origMinSide // > 0
		var secondOutSide = ratio * firstOutSide
		if !isMin {
			secondOutSide = firstOutSide / ratio
		}
		
		var newSize: CGSize
		if (isLandscape && isMin) || (!isLandscape && !isMin) {
			newSize = CGSize(width: secondOutSide, height: firstOutSide)
		}
		else {
			newSize = CGSize(width: firstOutSide,  height: secondOutSide)
		}
		
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
	
}


extension ViewController: QLPreviewControllerDataSource {
	func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
		return 1
	}
	
	func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
		guard let url = Bundle.main.url(forResource: String(index), withExtension: "png") else {
			fatalError("Could not load \(index)")
		}
		return url as QLPreviewItem
	}
	
}
