//
//  RootViewController.swift
//  nBack
//
//  Created by PT2051 on 2018/12/14.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import WebKit

class RootViewController: UIViewController {

    @IBOutlet var polyWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        polyWebView.navigationDelegate = self
        
        let path: String = Bundle.main.path(forResource: "poly", ofType: "html")!
        let localHtmlUrl: URL = URL(fileURLWithPath: path, isDirectory: false)
        
        polyWebView.scrollView.bounces = false
        polyWebView.scrollView.isScrollEnabled = false
        polyWebView.isOpaque = false
        polyWebView.scrollView.backgroundColor = UIColor.clear
        polyWebView.layer.backgroundColor = UIColor.clear.cgColor
        polyWebView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
    }

}

extension RootViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let execJS: String = "init(4);"
        webView.evaluateJavaScript(execJS, completionHandler: { (object, error) -> Void in
            // jsの関数実行結果
            // js側で戻り値を返すこともできる
        })
    }
}
