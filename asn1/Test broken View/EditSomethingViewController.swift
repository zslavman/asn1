//
//  EditSomeViewController.swift
//  Teamly
//
//  Created by Viacheslav on 30/07/19.
//

import Foundation
import UIKit


enum WhatEdit {
	case groupInfo
	case teamInfo
	case userInfo
}

class EditSomethingViewController: UIViewController {
	
	public var dataSourceElement: WhatEdit!
	private var newName = "Vasya"
	private var oldName = ""
	private var newAvaURL = ""
	private var oldAvaURL = ""
	private var saveBarButton: UIBarButtonItem!
	private var changeNameAndAvatarView: ChangeNameAndAvatarView!
	private let imagePicker = UIImagePickerController()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBackingClick)))
		setupNavbar()
		setupTopbarView()
	}
	
	
	private func setupNavbar() {
		navigationItem.title = "Edit"
		saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(didTapSaveButton))
		navigationItem.rightBarButtonItem = saveBarButton
		saveBarButton.isEnabled = false
		let backBttn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
		navigationItem.setLeftBarButton(backBttn, animated: false)
	}
	
	
	private func setupTopbarView() {
		changeNameAndAvatarView = ChangeNameAndAvatarView.initFromNib()
		changeNameAndAvatarView.delegate = self
		changeNameAndAvatarView.translatesAutoresizingMaskIntoConstraints = false
		changeNameAndAvatarView.updateView(name: newName, avatarURL: newAvaURL)
		
		view.addSubview(changeNameAndAvatarView)
		NSLayoutConstraint.activate([
			changeNameAndAvatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			changeNameAndAvatarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			changeNameAndAvatarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			])
	}
	
	
	internal func updateAvaURL(_ sourceId: String) {
		newAvaURL = sourceId == "" ? "" : "sourceId:" + sourceId
		//viewModel.didTapSaveButton(updatedGroupName: newGroupName ?? "", avaURL: newAvaURL!)
	}
	
	
	@objc private func didTapSaveButton() {
		let isChanged = newName != oldName || newAvaURL != oldAvaURL
		if isChanged {
			//viewModel.didTapSaveButton(updatedGroupName: newGroupName ?? "", avaURL: newAvaURL ?? "")
			navigationController?.popViewController(animated: false)
		}
	}
	
	
	@objc private func goBack() {
		self.navigationController?.popViewController(animated: false)
	}
	
	
	@objc private func onBackingClick() {
		view.endEditing(true)
	}
	
}


extension EditSomethingViewController: EditImageAndNameDelegate {
	
	
	func nameTextFieldDidChange(_ text: String) {
		newName = text
		saveBarButton.isEnabled = true
		//saveBarButton.isEnabled = (newName != oldName)
	}
	
	func didTapEditImageButton() {
//		imagePicker.sourceType = .photoLibrary
//		imagePicker.allowsEditing = true
//
//		let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//		let takePhotoAct = UIAlertAction(title: "Take photo", style: .default) {
//			_ in
//			print()
//		}
//		takePhotoAct.actionImage = #imageLiteral(resourceName: "camera")
//		let selectPhotoAct = UIAlertAction(title: "Select from gallery", style: .default) {
//			_ in
//			HUD.flash(.progress)
//			self.present(self.imagePicker, animated: true, completion: {
//				HUD.hide()
//			})
//		}
//		selectPhotoAct.actionImage = #imageLiteral(resourceName: "gallery")
//		let delPhotoAct = UIAlertAction(title: "Delete", style: .destructive) {
//			_ in
//			self.updateAvaURL("")
//		}
//		let cancelAct = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//		delPhotoAct.actionImage = #imageLiteral(resourceName: "delete")
//		actionSheetVC.addAction(takePhotoAct)
//		actionSheetVC.addAction(selectPhotoAct)
//		if newAvaURL != "" {
//			actionSheetVC.addAction(delPhotoAct)
//		}
//		actionSheetVC.addAction(cancelAct)
//		view.endEditing(true)
//		present(actionSheetVC, animated: true)
	}
	
}


protocol EditImageAndNameDelegate: class {
	func nameTextFieldDidChange(_ text: String)
	func didTapEditImageButton()
}

class ChangeNameAndAvatarView: UIView, UITextFieldDelegate {
	
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var imageButton: UIButton!
	let camera: UIImageView = {
		let icon = UIImageView(image: #imageLiteral(resourceName: "Steve-Jobs"))
		icon.contentMode = .scaleAspectFit
		icon.translatesAutoresizingMaskIntoConstraints = false
		icon.alpha = 0.9
		return icon
	}()
	let cameraIcon: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		return view
	}()
	let iconSize: CGFloat = 24
	let buttonSize: CGFloat = 40
//	private lazy var avatarLoader: AvatarImageViewLoader = {
//		return AvatarImageKingfisherLoader.build()
//	}()
	weak var delegate: EditImageAndNameDelegate?
	private var name: String = ""
	private var avatarURL: String = ""
	
	
	public static func initFromNib() -> ChangeNameAndAvatarView {
		//let thisView = Bundle.main.loadNibNamed("ChangeNameAndAvatarView", owner: self, options: nil)?.first as! ChangeNameAndAvatarView
		let myClassnib = UINib(nibName: "ChangeNameAndAvatarView", bundle: nil)
		let thisView = myClassnib.instantiate(withOwner: nil, options: nil)[0] as! ChangeNameAndAvatarView
		return thisView
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		//imageButton.setBackgroundColor(color: UIColor.black)
		imageButton.layer.cornerRadius = imageButton.frame.size.width/2
		imageButton.layer.masksToBounds = true
		addCameraIcon()
	}
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		nameTextField.becomeFirstResponder()
	}
	
	public func updateView(name: String, avatarURL: String) {
		self.name = name
		nameTextField.text = name
		self.avatarURL = avatarURL
		setupUserAvatar()
	}
	
	private func addCameraIcon() {
		cameraIcon.layer.cornerRadius = imageButton.frame.size.width/2
		cameraIcon.layer.masksToBounds = true
		addSubview(cameraIcon)
		cameraIcon.addSubview(camera)
		NSLayoutConstraint.activate([
			cameraIcon.widthAnchor.constraint(equalToConstant: buttonSize),
			cameraIcon.heightAnchor.constraint(equalToConstant: buttonSize),
			cameraIcon.centerXAnchor.constraint(equalTo: imageButton.centerXAnchor),
			cameraIcon.centerYAnchor.constraint(equalTo: imageButton.centerYAnchor),
			
			camera.widthAnchor.constraint(equalToConstant: iconSize),
			camera.heightAnchor.constraint(equalToConstant: iconSize),
			camera.centerXAnchor.constraint(equalTo: cameraIcon.centerXAnchor),
			camera.centerYAnchor.constraint(equalTo: cameraIcon.centerYAnchor),
			])
	}
	
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let text: NSString = (textField.text ?? "") as NSString
		let updatedText = text.replacingCharacters(in: range, with: string)
		delegate?.nameTextFieldDidChange(updatedText)
		return true
	}
	
	
	@IBAction func onImageBttnClick(_ sender: UIButton) {
		print("Clicked!")
		delegate?.didTapEditImageButton()
	}
	
	
	private func setupUserAvatar() {
		let placeholder = #imageLiteral(resourceName: "ic_typing")
		guard !avatarURL.isEmpty else {
			imageButton.setImage(placeholder, for: .normal)
			return
		}
//		avatarLoader.download(originalURL: avatarURL) {
//			[weak imageButton] reponseItem in
//			guard let image = reponseItem.value?.image else { return }
//			DispatchQueue.main.async {
//				imageButton?.setImage(image, for: .normal)
//				HUD.hide()
//			}
//		}
	}
	
}
