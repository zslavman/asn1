//
//  KeyChain.swift
//  Teamly
//
//  Created by User on 20/03/19.
//

import Foundation

class KeyChain {
	
	// saving takes place in UserCredentialsStorageImp before this var call
	/// Get current user unique name
	public static var getUserName: String {
		let defaults = UserDefaults(suiteName: Cipher.suiteName)!
		return defaults.value(forKey: "Username") as! String
	}
	public static var accountKeyVersion: Int32 {
		get {
			guard let data = readKey(keyName: "currentAccountKeyVersion") else { return -1 }
			// Data -> Int32
			let number = data.withUnsafeBytes {
				(pointer: UnsafePointer<Int32>) -> Int32 in
				return pointer.pointee // reading 4 bytes of data
			}
			return number
		}
		set {
			var newValueCopy = newValue
			// Int32 -> Data
			let newData = Data(bytes: &newValueCopy, count: MemoryLayout.size(ofValue: newValueCopy))
			saveKey(keyName: "currentAccountKeyVersion", dataKey: newData)
		}
	}
	// Capabilities -> Keychain Sharing -> group name
	public static let accessGroup = "8RTU5H2QPQ.com.teamy.KeychainSharingGroup"

	
	public static func readKey(keyName: String) -> Data? {
		var query = createQuery(service: keyName)
		query[kSecMatchLimit] 		= kSecMatchLimitOne
		query[kSecReturnAttributes] = kCFBooleanTrue
		query[kSecReturnData] 		= kCFBooleanTrue
		
		// Try to fetch the existing keychain item that matches the query
		var queryResult: AnyObject?
		let status = withUnsafeMutablePointer(to: &queryResult) {
			SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
		}
		// Check the return status
		guard status != errSecItemNotFound else {
			//print("KeyChain reading error - no keyitem found")
			return nil
		}
		guard status == noErr else {
			print("KeyChain reading error with status \(status)")
			return nil
		}
		// Parse the password string from the query result
		if let existingItem = queryResult as? [String: AnyObject]{
			let dataKey = existingItem[kSecValueData as String] as? Data
			// let version = existingItem[kSecAttrLabel as String] as? String
			print("KeyChain reading sucess")
			return dataKey
		}
		else {
			print("KeyChain reading error - unexpected password data!")
			return nil
		}
	}
	
	
	
	public static func saveKey(keyName: String, dataKey: Data, ver: Int32 = 0) {
		var query = createQuery(service: keyName)
		
		// Check for an existing item in the keychain
		if keyIsExists(keyName: keyName) {
			// Update the existing item with the new data
			let attributesToUpdate: [NSObject: Any] = [
				kSecValueData 		: dataKey,
				kSecAttrLabel 		: String(ver)
			]
			let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
			if status != noErr {
				print("KeyChain saving error with status \(status)")
			}
			else {
				print("KeyChain update success!")
			}
		}
		// If no keyitem found
		else {
			// Add a the new item to the keychain
			query[kSecValueData] 		= dataKey
			query[kSecAttrAccessible] 	= kSecAttrAccessibleAlways
			let status = SecItemAdd(query as CFDictionary, nil)
			if status != noErr {
				print("KeyChain saving error with status \(status)")
			}
			else {
				print("KeyChain saving success!")
			}
		}
	}
	
	
	private static func createQuery(service: String) -> [NSObject: Any] {
		let query: [NSObject: Any] = [
			kSecClass 			: kSecClassGenericPassword,
			kSecAttrService 	: service,
			kSecAttrAccount		: getUserName,
			kSecAttrAccessGroup	: accessGroup,
			//kSecReturnAttributes: kCFBooleanTrue,
			//kSecReturnData 		: kCFBooleanTrue,
			//kSecAttrAccessible	: kSecAttrAccessibleAlwaysThisDeviceOnly,
		]
		return query
	}
	
	
	
	public static func keyIsExists(keyName: String) -> Bool {
		return readKey(keyName: keyName) != nil
	}
	
	
	private static func deleteKey(keyName: String) {
		let query = createQuery(service: keyName)
		let resultCodeDelete = SecItemDelete(query as CFDictionary)
		
		if resultCodeDelete != noErr {
			print("Error deleting from Keychain: \(resultCodeDelete)")
			return
		}
		print("Key successfully deleted!")
	}
	
	
	//-------------
	
	public static func savePairRSA(keys: KeyPairRSA, type: KeyTag) {
		let commonQuery: [NSObject : Any] = [
			kSecClass            	: kSecClassKey,
			kSecAttrKeyType      	: kSecAttrKeyTypeRSA,
			kSecReturnPersistentRef	: false,
			kSecAttrAccessGroup		: KeyChain.accessGroup,
			kSecAttrAccessible 		: kSecAttrAccessibleAlways,
			kSecAttrApplicationTag 	: (type == .accountKey) ? String(accountKeyVersion) : getUserName, // 123  | atag
			kSecAttrLabel			: (type == .accountKey) ? getUserName : "",			// John | labl
			kSecAttrApplicationLabel: type.rawValue, 									// accountKey	klbl(binData)
		]
		var privQuery = commonQuery
		privQuery[kSecValueData] 	= keys.privateDataKey
		privQuery[kSecAttrKeyClass] = kSecAttrKeyClassPrivate				//	1
		var pubQuery = commonQuery
		pubQuery[kSecValueData]		= keys.publicDataKey
		pubQuery[kSecAttrKeyClass]	= kSecAttrKeyClassPublic				// 	0
		
		//check if keys already exists
		var exists = false
		if readRSA(readyRequest: privQuery) != nil {
			print("Key with type \(type.rawValue) not saved bcs it allready exists")
			exists = true
		}
		if readRSA(readyRequest: pubQuery) != nil {
			print("Key with type \(type.rawValue) not saved bcs it allready exists")
			exists = true
		}
		if exists {
			return
		}
		let privSaveStatus = SecItemAdd(privQuery as CFDictionary, nil)
		let pubSaveStatus = SecItemAdd(pubQuery as CFDictionary, nil)
		
		if privSaveStatus != errSecSuccess || pubSaveStatus != errSecSuccess {
			print("Error \(privSaveStatus) while save KeyPair")
			return
		}
		print("KeyPair successfully saved")
	}
	
	
	
	public static func savePrivateAccountKeyRSA(dataKey: Data, version: Int32) {
		let query: [NSObject : Any] = [
			kSecClass            	: kSecClassKey,
			kSecAttrKeyType      	: kSecAttrKeyTypeRSA,
			kSecReturnPersistentRef	: false,
			kSecAttrAccessGroup		: accessGroup,
			kSecAttrAccessible 		: kSecAttrAccessibleAlways,
			kSecAttrApplicationTag 	: String(version),
			kSecAttrLabel			: getUserName,
			kSecAttrApplicationLabel: KeyTag.accountKey.rawValue,
			kSecValueData 			: dataKey,
			kSecAttrKeyClass 		: kSecAttrKeyClassPrivate,
		]
		
		if readRSA(access: .privateA, type: .accountKey, ver: String(version), readyRequest: nil) != nil {
			//TODO: key update
			let attributesToUpdate: [NSObject: Any] = [
				kSecValueData 			: dataKey,
				kSecAttrApplicationTag	: String(version)
			]
			let saveStatus = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
			if saveStatus != errSecSuccess {
				print("Error \(saveStatus) while updating private account key")
				return
			}
			print("Private account key successfully updated")
		}
		else {
			//TODO: key save
			let saveStatus = SecItemAdd(query as CFDictionary, nil)
			if saveStatus != errSecSuccess {
				print("Error \(saveStatus) while save private account key")
				return
			}
			print("Private account key successfully saved")
		}
	}
	
	
	
	
	
	
	/// Forming base query for reading RSA-key
	private static func readQueryRSA() -> [NSObject : Any] {
		let query: [NSObject : Any] = [
			kSecClass            	: kSecClassKey,			// class
			kSecAttrKeyType      	: kSecAttrKeyTypeRSA,	// type
			kSecAttrAccessGroup		: KeyChain.accessGroup,
			kSecReturnAttributes	: true,
			kSecReturnData 			: true,					// r_Data
			kSecMatchLimit 			: kSecMatchLimitOne,
			kSecAttrKeyClass		: kSecAttrKeyClassPrivate,
			kSecAttrLabel			: getUserName 			// accauntName
		]
		return query
	}
	
	
	/// Get RSA-key on specific request (return last version if "ver" has no parameter)
	public static func readRSA(access: AccessIdentif, type: KeyTag, ver: String? = nil, readyRequest: [NSObject : Any]? = nil) -> Data? {
		var query = readQueryRSA()
		if access == .publicA {
			query[kSecAttrKeyClass] = kSecAttrKeyClassPublic
		}
		if let version = ver, type == .accountKey {
			query[kSecAttrApplicationTag] = version
		}
		if type == .accountKey && accountKeyVersion > -1 {
			query[kSecAttrApplicationTag] = String(accountKeyVersion)
		}
		if let rR = readyRequest {
			query = rR
			query.removeValue(forKey: kSecValueData)
			query[kSecReturnAttributes] = true
			query[kSecReturnData] 		= true
			query[kSecMatchLimit] 		= kSecMatchLimitOne
		}
		// Try to fetch the existing keychain item that matches the query
		var queryResult: AnyObject?
		let status = withUnsafeMutablePointer(to: &queryResult) {
			SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
		}
		// Check the return status
		guard status != errSecItemNotFound else {
			print("KeyChain reading error - no keyitem found"); return nil
		}
		guard status == noErr else {
			print("KeyChain reading error with status \(status)"); return nil
		}
		// Parse the password string from the query result
		if let existingItem = queryResult as? [String: AnyObject]{
			let dataKey = existingItem[kSecValueData as String] as? Data
			// let version = existingItem[kSecAttrLabel as String] as? String
			print("KeyChain reading sucess")
			return dataKey
		}
		else {
			print("KeyChain reading error - unexpected data!")
			return nil
		}
	}
	
	
	/// Get RSA-key on specific request
	public static func readRSA(readyRequest: [NSObject : Any]) -> Data? {
		return readRSA(access: .privateA, type: .accountKey, ver: nil, readyRequest: readyRequest)
	}
	
	
	/// Get all private RSA-keys for current account
	public static func readAllprivateRSA() -> [Int32 : Data]? {
		var query = readQueryRSA()
		query[kSecMatchLimit] = kSecMatchLimitAll
		var queryResult: AnyObject?
		var keys = [Int32 : Data]()
		
		let status = withUnsafeMutablePointer(to: &queryResult) {
			SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
		}
		guard status != errSecItemNotFound else {
			print("KeyChain reading error - no keyitem found"); return nil
		}
		guard status == noErr else {
			print("KeyChain reading error with status \(status)"); return nil
		}
		if let keysArray = queryResult as? [[String: AnyObject]] {
			for itemKey in keysArray {
				let ver = itemKey[kSecAttrApplicationTag as String] as? String
				let data = itemKey[kSecValueData as String] as? Data
				if let version = ver, let keyData = data {
					if let versionInt = Int32(version) {
						keys[versionInt] = keyData
					}
				}
			}
			print("KeyChain reading sucess")
			return keys.isEmpty ? nil : keys
		}
		else {
			print("KeyChain reading error - unexpected password data!")
			return nil
		}
	}
	
	
	/// Checking if RSA key-pair existing
	public static func isKeyPairExistsRSA(type: KeyTag) -> Bool {
		return readRSA(access: .privateA, type: type) != nil
	}
	
	
	
}

