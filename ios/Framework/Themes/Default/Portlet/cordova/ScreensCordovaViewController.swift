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
import Cordova
public class ScreensCordovaViewController: CDVViewController, UIWebViewDelegate {

	var cdvDelegate: CDVUIWebViewNavigationDelegate?

	let jsCallHandler: (String, String) -> Void
	let onPageLoadFinished: (Error?) -> Void

	public init(jsCallHandler: @escaping (String, String) -> Void, onPageLoadFinished: @escaping (Error?) -> Void) {
		self.jsCallHandler = jsCallHandler
		self.onPageLoadFinished = onPageLoadFinished
		super.init(nibName: nil, bundle: nil)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("you have to use the init(jsCallsHandler: _) initializer")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		register(ScreensBridgePlugin(webViewEngine: self.webViewEngine), withPluginName: "screensbridgeplugin")
		cdvDelegate = CDVUIWebViewNavigationDelegate(enginePlugin: self.webViewEngine as! CDVPlugin)
	}

	public func inject(script: InjectableScript, completionHandler: ((Any?, Error?) -> Void)?) {
		
		self.webViewEngine.evaluateJavaScript(script.content, completionHandler: completionHandler)
	}

	open func load(request: URLRequest) {
		webViewEngine.load(request)
	}

	open func load(htmlString: String) {
		let server = SessionContext.currentContext?.session.server ?? ""
		initialNavigation = webViewEngine.loadHTMLString(htmlString, baseURL: URL(string: server)!) as? WKNavigation
	}

	// MARK: UIWebViewDelegate

	public func webView(_ webView: UIWebView,
	                    shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		return cdvDelegate?.webView(webView, shouldStartLoadWith: request, navigationType: navigationType) ?? false

	}

	public func handleJsCall(namespace: String, message: String) {
		jsCallHandler(namespace, message)
	}

	public func webViewDidStartLoad(_ webView: UIWebView) {
		cdvDelegate?.webViewDidStartLoad(webView)
	}

	public func webViewDidFinishLoad(_ webView: UIWebView) {
		cdvDelegate?.webViewDidFinishLoad(webView)
	}

	public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
		cdvDelegate?.webView(webView, didFailLoadWithError: error)
		onPageLoadFinished(nil)
	}
}
