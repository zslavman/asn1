//
//  RSAManager.swift
//  Teamly
//
//  Created by User on 14/02/19.
//

import Foundation
import CommonCrypto


enum DescriptionIdentifier: String {
	case publicDescr  = "----- PUBLIC KEY ------"
	case privateDescr = "----- PRIVATE KEY -----"
}
enum KeyTag: String {
	case accountKey = "accountPublicKey"// for crypt/decrypt
	case deviceKey = "devicePublicKey" 	// for register another device
}
enum AccessIdentif {
	case publicA
	case privateA
}

struct KeyPairRSA {
	var privateDataKey: Data
	var publicDataKey: Data
}


class Cipher {
	
	private static let cryptoSecKeyAlgorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA1 // works lower then 224 bytes only
	public static let suiteName = "group.com.teamyIntermodules"
	
	//MARK:- RSA Key-pair Generation method

	/*
	* Most proper native key-pair creation. If keys exists - method will return them
	*/
	@discardableResult
	public static func generatePair_RSA(type: KeyTag) -> KeyPairRSA? {
		// check if exists
//		if let privateKey = KeyChain.readRSA(access: .privateA, type: type) {
//			guard let publicKey = KeyChain.readRSA(access: .publicA, type: type) else { fatalError() }
//			return KeyPairRSA(privateDataKey: privateKey, publicDataKey: publicKey)
//		}
//		else {
			let commonKeyAttr: [NSObject: Any] = [
				kSecClass				: kSecClassKey,
				kSecReturnRef			: false,
				kSecReturnData			: true
			]
			let keyPairAttr: [NSObject: Any] = [
				kSecAttrKeyType 		: kSecAttrKeyTypeRSA,
				kSecAttrKeySizeInBits 	: 2048,
				kSecPublicKeyAttrs		: commonKeyAttr,
				kSecPrivateKeyAttrs		: commonKeyAttr,
			]
			var pubSecKey: SecKey?
			var privSecKey: SecKey?
			// generate keys
			let statusGenerate = SecKeyGeneratePair(keyPairAttr as CFDictionary, &pubSecKey, &privSecKey)
				guard statusGenerate == errSecSuccess else {
				print("Error while generate pair: \(statusGenerate)")
				return nil
			}
			guard let pubKey = pubSecKey, let privKey = privSecKey else { return nil }
			let privDataKey = convertSecKeyToData(secKey: privKey)!
			let pubDataKey = convertSecKeyToData(secKey: pubKey)!
			
			let keyPairRSA = KeyPairRSA(privateDataKey: privDataKey, publicDataKey: pubDataKey)
			if type == .deviceKey {
				KeyChain.savePairRSA(keys: keyPairRSA, type: .deviceKey)
			}
			return keyPairRSA
//		}
	}
	
	
//	/// native random key-pair creation with save into persistent store (return: public key)
//	@discardableResult
//	public static func generatePair_RSA2(withTag: KeyTag) -> Data? {
//		deleteSecureKeyPair(withTag: withTag)
//
//		let attributes: [NSObject: Any] = [
//			kSecAttrKeyType			: kSecAttrKeyTypeRSA,
//			kSecAttrKeySizeInBits	: 2048,
//			kSecPrivateKeyAttrs 	: [
//				kSecAttrIsPermanent 	: false,
//				kSecAttrApplicationTag	: withTag.rawValue.data(using: String.Encoding.utf8)!
//			]
//		]
//		var error: Unmanaged<CFError>?
//		if let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) {
//			// Gets the public key associated with the given private key.
////			let publicKey = SecKeyCopyPublicKey(privateKey)!
//			// save to keychain
//			let privDataKey = convertSecKeyToData(secKey: privateKey)!
//			return privDataKey
//		}
//		else {
//			print(error!.takeRetainedValue() as Error)
//			return nil
//		}
//	}
	
	/*----------------------------------------------------------------------*/
	
	
	//MARK:- RSA-Encrypt/Decrypt
	
	// use this method
	public static func encrypt_RSA(data: Data, rsaPublicKeyRef: SecKey) -> Data? {
		var error: Unmanaged<CFError>?
		guard let encrData = SecKeyCreateEncryptedData(rsaPublicKeyRef,
													   cryptoSecKeyAlgorithm,
													   data as CFData,
													   &error)
			else {
				print("Encrypting error: \(error!)")
				return nil
		}
		return encrData as Data
	}
	
	
	public static func encrypt_RSA(str: String, rsaPublicKeyRef: SecKey) -> Data? {
		guard let messageData = str.data(using: String.Encoding.utf8) else {
			print("Bad text to encrypt")
			return nil
		}
		return encrypt_RSA(data: messageData, rsaPublicKeyRef: rsaPublicKeyRef)
	}
	
	/// convert DataKey into SecKey (for local use only)
	public static func encrypt_RSA(data: Data, rsaPublicKeyData: Data) -> Data? {
		guard let pubSecKey = convertKeyDataToSecKey(key: rsaPublicKeyData) else {
			return nil
		}
		return encrypt_RSA(data: data, rsaPublicKeyRef: pubSecKey)
	}
	
	
	public static func decrypt_RSA(data: Data, privKey: Data? = nil) -> Data? {
		var privDataKey: Data
		if let dataKey = privKey {
			privDataKey = dataKey
		}
		else {
			privDataKey = KeyChain.readRSA(access: .privateA, type: .accountKey)!
		}
		guard let privSecKey = convertKeyDataToSecKey(key: privDataKey, isPublic: false) else { return nil }
		var error: Unmanaged<CFError>?
		guard let decryptData = SecKeyCreateDecryptedData(privSecKey,
														  cryptoSecKeyAlgorithm,
														  data as CFData,
														  &error)
			else {
				print("Decrypting error. Error: \(error!)")
				return nil
		}
		print("Successfully decrypted!")
		return decryptData as Data
	}
	
	
	public static func decrypt_RSA(str: String) -> Data? {
		guard let messageData = Data(base64Encoded: str) else {
			print("Bad message to decrypt")
			return nil
		}
		return decrypt_RSA(data: messageData)
	}

	/*----------------------------------------------------------------------*/
	
	
	//MARK:- other (for RSA)
	
	public static func deleteCommonSecKeys() {
		let secItemClasses = [
			kSecClassGenericPassword,
		  	kSecClassInternetPassword,
			kSecClassCertificate,
			kSecClassKey,
			kSecClassIdentity
		]
		for secItemClass in secItemClasses {
			let dictionary = [kSecClass as String:secItemClass]
			let status = SecItemDelete(dictionary as CFDictionary)
			if status == errSecSuccess {
				print("Successfully deletre SecKey for \(secItemClass)")
			}
		}
	}
	
	
//	public static func getSecKeyFromKeychain(withTag: KeyTag, access: AccessIdentif, printExists: Bool = true) -> SecKey? {
//		let parameters:[NSObject : Any]  = [
//			kSecClass				: kSecClassKey,
//			kSecAttrKeyClass		: (access == .publicA) ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate,
//			kSecAttrKeyType			: (withTag == .accountKey) ? kSecAttrKeyTypeRSA : kSecAttrKeyTypeEC,
//			kSecAttrApplicationTag	: withTag.rawValue,
//			kSecReturnRef			: true
//		]
//		var ref: AnyObject?
//		let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
//		if status == errSecSuccess {
//			return ref as! SecKey?
//		}
//		if printExists {
//			print("Error: key '\(access)' not found!")
//		}
//		return nil
//	}
	
	
	/// convert DataKey -> SecKey
	public static func convertKeyDataToSecKey(key: Data, isPublic: Bool = true, tagName: String = "000") -> SecKey? {
		guard let pubkeyData = stripPublicKeyHeader(key) else {
			return nil
		}
//		let pubkeyData = key
		let queryFilter: [NSObject : Any] = [
			kSecClass             	: kSecClassKey,
			kSecAttrKeyType       	: kSecAttrKeyTypeRSA,
			kSecReturnPersistentRef	: false,
			kSecAttrKeyClass        : (isPublic) ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate,
			kSecAttrKeySizeInBits 	: 2048,
			kSecAttrAccessGroup		: KeyChain.accessGroup,
			kSecAttrAccessible 		: kSecAttrAccessibleAlways,
			kSecAttrApplicationTag 	: tagName,
			kSecAttrLabel			: tagName,
			kSecAttrApplicationLabel: "accountKey",
		]
		var error: Unmanaged<CFError>?
		if let secKeyPublic = SecKeyCreateWithData(pubkeyData as CFData, queryFilter as CFDictionary, &error) {
			return secKeyPublic
		}
		print("Error can't create SecKey WithData, error: \(error!)")
		return nil
	}
	
	
	
	/// convert SecKey -> DataKey
	public static func convertSecKeyToData(secKey: SecKey) -> Data? {
		var error: Unmanaged<CFError>?
		if let dataKey = SecKeyCopyExternalRepresentation(secKey, &error) {
			return dataKey as Data
		}
		print(error!.takeRetainedValue() as Error)
		return nil
	}
	
	
	
	/*
	* Verifies that the supplied key is in fact a X509 public key, and strips its header.
	*/
	/// Returns the RSA public key with stripped header
	/// - Parameter pubkey: X509 public key
	public static func stripPublicKeyHeader(_ pubkey: Data) -> Data? {
		if pubkey.count == 0 {
			return nil
		}
		var keyAsArray = [UInt8](repeating: 0, count: pubkey.count / MemoryLayout<UInt8>.size)
		(pubkey as NSData).getBytes(&keyAsArray, length: pubkey.count)
		
		var idx = 0
		if (keyAsArray[idx] != 0x30) {
			print("Error: provided key doesn't have a valid ASN.1 structure (first byte should be 0x30)")
			return nil
		}
		idx += 1
		
		if (keyAsArray[idx] > 0x80) {
			idx += Int(keyAsArray[idx]) - 0x80 + 1
		}
		else {
			idx += 1
		}
		/*
		* If current byte is 0x02, it means the key doesn't have a X509 header (it contains only modulo & public exponent).
		* In this case, we can just return the provided DER data as is
		*/
		if (Int(keyAsArray[idx]) == 0x02) {
			return pubkey
		}
		// RSA OID header
		let seqiod = [UInt8](arrayLiteral: 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00)
		for i in idx..<idx+seqiod.count {
			if (keyAsArray[i] != seqiod[i - idx]) {
				print("Error: provided key doesn't have a valid X509 header.")
				return nil
			}
		}
		idx += seqiod.count
		if (keyAsArray[idx] != 0x03) {
			print("Error: invalid byte at index \(idx) (\(keyAsArray[idx])) for public key header.")
			return nil
		}
		idx += 1
		if (keyAsArray[idx] > 0x80) {
			idx += Int(keyAsArray[idx]) - 0x80 + 1;
		}
		else {
			idx += 1
		}
		if (keyAsArray[idx] != 0x00) {
			print("Error: invalid byte at index \(idx) (\(keyAsArray[idx])) for public key header.")
			return nil
		}
		idx += 1
		return pubkey.subdata(in: idx..<keyAsArray.count)
		//return pubkey.subdata(in: NSMakeRange(idx, keyAsArray.count - idx).toRange()!)
	}
	
	
	
	public static func getKeyData(withTag: KeyTag, access: AccessIdentif) -> Data? {
		let parameters:[NSObject : Any]  = [
			kSecClass				: kSecClassKey,
			kSecAttrKeyClass		: (access == .publicA) ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate,
			kSecAttrKeyType			: kSecAttrKeyTypeRSA,
			kSecAttrApplicationTag	: withTag.rawValue.data(using: String.Encoding.utf8)!,
			kSecReturnData			: true
		]
		var data: AnyObject?
		let status = SecItemCopyMatching(parameters as CFDictionary, &data)
		if status == errSecSuccess {
			return data as? Data
		}
		else {
			print("Error: key '\(withTag.rawValue)' not found!")
			return nil
		}
	}
	
	
	public static func deleteSecureKeyPair(withTag: KeyTag) {
		let deleteQuery: [NSObject : Any] = [
			kSecClass				: kSecClassKey,
			kSecAttrApplicationTag 	: withTag.rawValue,
		]
		let status = SecItemDelete(deleteQuery as CFDictionary)
		if status == errSecSuccess {
			print("Keys with tag \(withTag.rawValue) successfully deleted!")
		}
		//		else {
		//			print("Nothing to delete!")
		//		}
	}
	
	
//	// Add RSA-key into keychain storage
//	@discardableResult
//	private static func addSecKeyToKeychain(secKey: SecKey, access: AccessIdentif, tagName: KeyTag) -> SecKey? {
//		let queryFilter: [NSObject : Any] = [
//			kSecClass            	: kSecClassKey,
//			kSecAttrKeyType      	: kSecAttrKeyTypeRSA,
//			kSecAttrApplicationTag 	: tagName.rawValue.data(using: String.Encoding.utf8)!,
//			//kSecAttrAccessible    : kSecAttrAccessibleWhenUnlocked,
//			kSecValueRef         	: secKey,
//			kSecAttrKeyClass      	: access == .privateA ? kSecAttrKeyClassPrivate : kSecAttrKeyClassPublic,
//			kSecReturnPersistentRef	: true
//		]
//		let result = SecItemAdd(queryFilter as CFDictionary, nil)
//		if (result != noErr && result != errSecDuplicateItem) {
//			print("Error, can't add key to keychain, status \(result)")
//			return nil
//		}
//		return Cipher.getSecKeyFromKeychain(withTag: tagName, access: .privateA)
//	}

	
	
	
	
	/*
	* Verifies that the supplied key is in fact a PEM RSA private key, and strips its header.
	* If the supplied key is PKCS#8, its ASN.1 header should be stripped. Otherwise (PKCS#1), the whole key data is left intact.
	*/
	/// Returns the private RSA key with stripped header
	///
	/// - Parameter privkey: RSA private key (PKCS#1 or PKCS#8)
	/// - Throws: Error if the input key is not a valid RSA PKCS#8 private key
	public static func stripPrivateKeyHeader(_ privkey: Data) -> Data? {
		if privkey.count == 0 {
			return nil
		}
		var keyAsArray = [UInt8](repeating: 0, count: privkey.count / MemoryLayout<UInt8>.size)
		(privkey as NSData).getBytes(&keyAsArray, length: privkey.count)
		
		//PKCS#8: magic byte at offset 22, check if it's actually ASN.1
		var idx = 22
		if keyAsArray[idx] != 0x04 {
			print("Error while strip header - it's actually not ASN.1 key!")
			return privkey
		}
		idx += 1
		
		//now we need to find out how long the key is, so we can extract the correct hunk
		//of bytes from the buffer.
		var len = Int(keyAsArray[idx])
		idx += 1
		let det = len & 0x80 //check if the high bit set
		if (det == 0) {
			//no? then the length of the key is a number that fits in one byte, (< 128)
			len = len & 0x7f
		}
		else {
			//otherwise, the length of the key is a number that doesn't fit in one byte (> 127)
			var byteCount = Int(len & 0x7f)
			if (byteCount + idx > privkey.count) {
				return nil
			}
			//so we need to snip off byteCount bytes from the front, and reverse their order
			var accum: UInt = 0
			var idx2 = idx
			idx += byteCount
			while (byteCount > 0) {
				//after each byte, we shove it over, accumulating the value into accum
				accum = (accum << 8) + UInt(keyAsArray[idx2])
				idx2 += 1
				byteCount -= 1
			}
			// now we have read all the bytes of the key length, and converted them to a number,
			// which is the number of bytes in the actual key.  we use this below to extract the
			// key bytes and operate on them
			len = Int(accum)
		}
		return privkey.subdata(in: idx..<idx + len)
	}
	
	
	public static func smartPrint(string: String, identifier: DescriptionIdentifier) {
		let prefix = identifier.rawValue
		let suffix: String = "\n"
		print("\(prefix)\n\(string)\(suffix)")
	}
	
	
	private static func printKeys() {
		let pubKey = getKeyData(withTag: .accountKey, access: .publicA)
		let privKey = getKeyData(withTag: .accountKey, access: .privateA)
		guard let pubData = pubKey, let privData = privKey else { return }
		print(pubData)
		smartPrint(string: pubData.base64EncodedString(), identifier: .publicDescr)
		print(privData)
		smartPrint(string: privData.base64EncodedString(), identifier: .privateDescr)
	}
	
	/*----------------------------------------------------------------------*/
	
	
	//MARK:- AES-CBC
	
	public static func encrypt_AES(data: Data, keyData: Data) -> Data? {
		return cryptAES_CBC(data: data, keyData: keyData, kCCMethod: kCCEncrypt)
	}
	
	
	public static func decrypt_AES(data: Data, keyData: Data) -> Data? {
		return cryptAES_CBC(data: data, keyData: keyData, kCCMethod: kCCDecrypt)
	}
	
	
	/// Encrypt/Decrypt message with AES-key
	///
	/// - Parameters:
	///   - data: data witch will be encrypted/decrypted
	///   - keyData: binary AES-key
	///   - kCCMethod: kCCEncrypt - encrypt, kCCDecrypt - decrypt
	private static func cryptAES_CBC(data: Data, keyData: Data, kCCMethod: Int) -> Data? {
		guard keyData.count == kCCKeySizeAES128 else { // kCCKeySizeAES128 = 16 (bytes)
			print("Invalid key length: ", keyData.count)
			return nil
		}
		let ivData = Data(bytes: [UInt8](repeating: 0, count: 16)) // salt
		let dataLength = data.count
		let cryptLength = size_t(dataLength + kCCBlockSizeAES128)
		var cryptData = Data(count: cryptLength)
		
		let keyLength = size_t(kCCKeySizeAES128)
		let options = CCOptions(kCCOptionPKCS7Padding) // 0
		var numBytesEncrypted: size_t = 0
		
		let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
			data.withUnsafeBytes {dataBytes in
				ivData.withUnsafeBytes {ivBytes in
					keyData.withUnsafeBytes {keyBytes in
						CCCrypt(CCOperation(kCCMethod),
								CCAlgorithm(kCCAlgorithmAES),
								options,
								keyBytes, keyLength,
								ivBytes,
								dataBytes, dataLength,
								cryptBytes, cryptLength,
								&numBytesEncrypted)
					}
				}
			}
		}
		if UInt32(cryptStatus) == UInt32(kCCSuccess) {
			cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
			//--------------
			if let crypt = String(data: cryptData, encoding: .utf8){
				let prefix = (kCCMethod == kCCEncrypt) ? "encrypted" : "decrypted"
				print("\(prefix)Data = \(crypt)")
			}
			//--------------
			generateKeyAES_CBC()
			return cryptData
		}
		else {
			print("AES crypt error with status: \(cryptStatus)")
			return nil
		}
	}
	
	@discardableResult
	public static func generateKeyAES_CBC() -> Data {
		var bytes = [UInt8](repeating: 0, count: kCCKeySizeAES128) // 16 elements
		let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		if status == errSecSuccess {
			let data = Data(bytes: bytes)
			return data
		}
		else {
			fatalError("Error while generating AES-key, status: \(status)")
		}
	}

	/*----------------------------------------------------------------------*/
	
	
	private static func addX509CertificateHeader(for keyData: Data) -> Data {
		if keyData.count == 140 {
			return Data([0x30, 0x81, 0x9F,
						 0x30, 0x0D,
						 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01,
						 0x05, 0x00,
						 0x03, 0x81, 0x8D, 0x00]) + keyData
		} else if keyData.count == 270 {
			return Data([0x30, 0x82, 0x01, 0x22,
						 0x30, 0x0D,
						 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01,
						 0x05, 0x00,
						 0x03, 0x82, 0x01, 0x0F, 0x00]) + keyData
		} else if keyData.count == 398 {
			return Data([0x30, 0x82, 0x01, 0xA2,
						 0x30, 0x0D,
						 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01,
						 0x05, 0x00,
						 0x03, 0x82, 0x01, 0x8F, 0x00]) + keyData
		} else if keyData.count == 526 {
			return Data([0x30, 0x82, 0x02, 0x22,
						 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01,
						 0x05, 0x00,
						 0x03, 0x82, 0x02, 0x0F, 0x00]) + keyData
		} else {
			return keyData
		}
	}
	
	
	// docs.microsoft.com/en-us/windows/desktop/seccertenroll/about-bit-string
	// habr.com/ru/post/150888/
	// en.wikipedia.org/wiki/X.690#Encoding
	
	public static func addHeaderForPubKey(_ derKey: Data) -> Data {
		var result = Data()
		var builder: [UInt8] = []
		let octetsArr: [UInt8] = encodedOctets(derKey.count + 1)
		let encodingLength: Int = octetsArr.count
		
		// Sequence of length 0xd made up of OID followed by NULL (RSA OID header)
		let OID: [UInt8] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
							0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
		// ASN.1 SEQUENCE
		builder.append(0x30)
		
		// Overall size, made of OID + bitstring encoding + actual key
		let size = OID.count + 2 + encodingLength + derKey.count
		let encodedSize = encodedOctets(size)
		builder.append(contentsOf: encodedSize)
		result.append(builder, count: builder.count)

		result.append(OID, count: OID.count)
		builder.removeAll(keepingCapacity: false)
		
		// last part
		builder.append(0x03)
		builder.append(contentsOf: encodedOctets(derKey.count + 1))
		builder.append(0x00) // End-of-Content (EOC)
		result.append(builder, count: builder.count)
		
		// Actual key bytes
		result.append(derKey)
		
		return result
	}
	
	
	/// convert PKCS1 to PKCS8
	public static func addHeaderForPrivKey(_ derKey: Data) -> Data {
		var result = Data()
		var builder: [UInt8] = []
		let privKeyHeaderVersion: [UInt8] = [0x02, 0x01, 0x00] // header "INTEGER 0"
		// Crypt algorithm identifier: 1.2.840.113549.1.1.1 rsaEncryption (PKCS #1)
		let OID: [UInt8] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, //"SEQUENCE" + "OBJECT IDENTIFIER" + "NULL"
							0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
		// ASN.1 SEQUENCE
		builder.append(0x30)
		
		let countsOfAddedHeaders = 1 + 1 + 1 + 1 // first bit for 4 headers
		
		// Overall size
		let sequenceSize = privKeyHeaderVersion.count + OID.count + derKey.count + countsOfAddedHeaders
		let sequence = splitToOctets(sequenceSize)
		builder.append(contentsOf: sequence)
		result.append(builder, count: builder.count)

		result.append(privKeyHeaderVersion, count: privKeyHeaderVersion.count)
		result.append(OID, count: OID.count)
		builder.removeAll(keepingCapacity: false)
		
		// last part
		builder.append(0x04) // 0x03 - BIT STRING, 0x04 - OCTET STRING
		builder.append(contentsOf: splitToOctets(derKey.count))
		result.append(builder, count: builder.count)
		
		// Actual key bytes
		result.append(derKey)
	
		return result
	}
	
	
	
	/// calculate array of bits which will take "int"-size (for BIT STRING)
	private static func encodedOctets(_ int: Int) -> [UInt8] {
		// Short form
		if int < 128 {
			return [UInt8(int)]
		}
		// Long form
		let i = (int / 256) + 1
		var len = int
		var firstBit = i + 0x80
		if firstBit > 0x82 { // don't know why
			firstBit = 0x82
		}
		var result: [UInt8] = [UInt8(firstBit)]
		
		for _ in 0..<i {
			result.insert(UInt8(len & 0xFF), at: 1)
			len = len >> 8
		}
		return result
	}
	
	
	
	/// calculate array of bits which will take "int"-size (for OCTET STRING)
	/* Some Examples:
	* 128 = [0x81, 0x80]
	* 129 = [0x81, 0x81]
	* 255 = [0x81, 0xff]
	* 256 = [0x82, 0x01]
	* 257 = [0x82, 0x01, 0x01]
	* 512 = [0x82, 0x02]
	* 513 = [0x82, 0x02, 0x01]
	* 768 = [0x82, 0x03]
	* 769 = [0x82, 0x03, 0x01]
	* 1024 = [0x82, 0x04
	* 1025 = [0x82, 0x04, 0x01]
	*/
	public static func splitToOctets(_ int: Int) -> [UInt8] {
		let array = encodedOctets(int)
		var toReturn = [UInt8]()
		for item in array {
			if item != 0x00 {
				toReturn.append(item)
			}
		}
		return toReturn
	}
	

	
}









