//
//  SUtils.swift
//  asn1
//
//  Created by Zinko Viacheslav on 22.04.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation


class SUtils {
	
	
	
	public static func convertDate(date: Date) -> String {
		let dateFormater = DateFormatter()
		dateFormater.locale = Locale(identifier: "RU")
		dateFormater.dateFormat = "HH:mm:ss"
		let dateString = dateFormater.string(from: date)
		return dateString
	}
	
	
	
}
