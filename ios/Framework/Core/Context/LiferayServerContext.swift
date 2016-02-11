/**
* Copyright (c) 2000-present Liferay, Inc. All rights reserved.
*
* This library is free software; you can redistribute it and/or modify it under
* the terms of the GNU Lesser General Public License as published by the Free
* Software Foundation; either version 2.1 of the License, or (at your option)
* any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
* details.
*/
import Foundation


@objc public class LiferayServerContext: NSObject {

	//MARK: Singleton type

	private struct StaticInstance {
		static var serverProperties: NSMutableDictionary?
	}


	//MARK: Public properties

	public class var server: String {
		get {
			loadContextFile()
			return StaticInstance.serverProperties!["server"] as! String
		}
		set {
			loadContextFile()
			StaticInstance.serverProperties!["server"] = newValue
		}
	}

	public class var companyId: Int64 {
		get {
			loadContextFile()
			return (StaticInstance.serverProperties!["companyId"] as! NSNumber).longLongValue
		}
		set {
			loadContextFile()
			StaticInstance.serverProperties!["companyId"] = NSNumber(longLong: newValue)
		}
	}

	public class var groupId: Int64 {
		get {
			loadContextFile()
			return (StaticInstance.serverProperties!["groupId"] as! NSNumber).longLongValue
		}
		set {
			loadContextFile()
			StaticInstance.serverProperties!["groupId"] = NSNumber(longLong: newValue)
		}
	}

	public class var factory: ScreensFactory {
		get {
			loadContextFile()
			return StaticInstance.serverProperties!["factory"] as! ScreensFactory
		}
		set {
			loadContextFile()
			StaticInstance.serverProperties!["factory"] = newValue
		}
	}

	public class var operationFactory: LiferayOperationFactory {
		get {
		loadContextFile()
		return StaticInstance.serverProperties!["operationFactory"] as! LiferayOperationFactory
		}
		set {
			loadContextFile()
			StaticInstance.serverProperties!["operationFactory"] = newValue
		}
	}


	//MARK: Public methods

	public class func propertyForKey(key: String) -> AnyObject? {
		loadContextFile()
		return StaticInstance.serverProperties![key]
	}

	public class func setPropertyValue(value: AnyObject, forKey key: String) {
		loadContextFile()
		return StaticInstance.serverProperties![key] = value
	}


	//MARK: Private methods

	private class func loadContextFile() {

		func createFactory() {
			guard let className = StaticInstance.serverProperties?["factory"] as? String else {
				StaticInstance.serverProperties!["factory"] = ScreensFactoryImpl()
				return
			}
			guard let factoryInstance = dynamicInit(className) as? ScreensFactory else {
				StaticInstance.serverProperties!["factory"] = ScreensFactoryImpl()
				return
			}

			StaticInstance.serverProperties!["factory"] = factoryInstance
		}

		func createOperationFactory() {
			guard let className = StaticInstance.serverProperties?["operationFactory"] as? String else {
				StaticInstance.serverProperties!["operationFactory"] = Liferay70OperationFactory()
				return
			}
			guard let factoryInstance = dynamicInit(className) as? LiferayOperationFactory else {
				StaticInstance.serverProperties!["operationFactory"] = Liferay70OperationFactory()
				return
			}

			StaticInstance.serverProperties!["operationFactory"] = factoryInstance
		}

		guard StaticInstance.serverProperties == nil else {
			return
		}

		let bundles = Array(NSBundle.allBundles(self).reverse())

		var found = false
		var foundFallback = false

		var i = 0
		let length = bundles.count

		while !found && i < length {
			let bundle = bundles[i++]

			if let path = bundle.pathForResource(PlistFile, ofType:"plist") {
				StaticInstance.serverProperties = NSMutableDictionary(contentsOfFile: path)
				createFactory()
				createOperationFactory()
				found = true
			}
			else {
				if let path = bundle.pathForResource(PlistFileSample, ofType:"plist") {
					StaticInstance.serverProperties = NSMutableDictionary(contentsOfFile: path)
					createFactory()
					createOperationFactory()
					foundFallback = true
				}
				else {
					StaticInstance.serverProperties = [
							"companyId": 10157,
							"groupId": 10184,
							"server": "http://localhost:8080"]
					createFactory()
					createOperationFactory()
				}
			}
		}

		if found {
			// everything is ok
		}
		else {
			if foundFallback {
				print("WARNING: \(PlistFile).plist file is not found. " +
						"Falling back to template \(PlistFileSample).list\n")
			}
			else {
				print("ERROR: \(PlistFileSample).plist file is not found. " +
						"Using default values which will work in a default Liferay bundle " +
						"running on localhost:8080\n")
			}
		}
	}

}

private let PlistFile = "liferay-server-context"
private let PlistFileSample = "liferay-server-context-sample"
