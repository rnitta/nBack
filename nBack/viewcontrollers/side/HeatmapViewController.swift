//
//  HeatmapViewController.swift
//  nBack
//
//  Created by PT2051 on 2018/12/31.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import WebKit
import BetterSegmentedControl
import SVGKit
import RxSwift
import RxCocoa
import RealmSwift

class HeatmapViewController: UIViewController {
    let realm = try! Realm()
    let disposeBag:DisposeBag = DisposeBag()
    var segmentIndex:Int = 0
    @IBOutlet var webView: WKWebView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var segmentView: BetterSegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebview()
        setupSegmentView()
        setupCloseButton()
        // Do any additional setup after loading the view.
    }
    
    private func setupCloseButton() {
        closeButton.backgroundColor = UIColor.clear
        
        if let svg = SVGKImage(named: "closeX_icon.svg") {
            closeButton.setImage(svg.uiImage, for: .normal)
            closeButton.tintColor = UIColor.gray
        }
        
        closeButton.rx.tap.subscribe {[unowned self] _ in
            self.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    
    private func setupSegmentView() {
        segmentView.segments = LabelSegment.segments(withTitles: [NSLocalizedString("heatmap_segmentFirst", comment: ""), NSLocalizedString("heatmap_segmentSecond", comment: "")],
                                                     normalFont: UIFont(name: "HiraginoSans-W3", size: 20)!,
                                                     selectedFont: UIFont(name: "HiraginoSans-W6", size: 20)!)
    }
    @IBAction func segmentIndexChanged(_ sender: BetterSegmentedControl) {
        segmentIndex = Int(sender.index)
        reloadMap()
    }
    
    private func setupWebview(){
        webView.navigationDelegate = self
        let path: String = Bundle.main.path(forResource: "heatmap", ofType: "html")!
        let localHtmlUrl: URL = URL(fileURLWithPath: path, isDirectory: false)
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.scrollView.backgroundColor = UIColor.white
        webView.layer.backgroundColor = UIColor.white.cgColor
        webView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
    }
    

}

extension HeatmapViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        reloadMap()
    }
    
    private func reloadMap() {
        webView.evaluateJavaScript(execJSString(), completionHandler: { _, _ in
            //print("ローディングアニメーションぶちこむ")
        })
    }
    
    private func execJSString() -> String {
        var calcdata:[String: Int] = [:]
        var griddata:[String: Int] = [:]
        
        if segmentIndex == 0 {
            calcdata = realm.objects(calcData.self).filter("timeStamp >= %@", Date().beginningOfThisMonth()).toHeatmapJson()
            griddata = realm.objects(gridData.self).filter("timeStamp >= %@", Date().beginningOfThisMonth()).toHeatmapJson()
        } else {
            calcdata = realm.objects(calcData.self).filter("timeStamp >= %@", Date().beginningOfThisMonth()).perfect().toHeatmapJson()
            griddata = realm.objects(gridData.self).filter("timeStamp >= %@", Date().beginningOfThisMonth()).perfect().toHeatmapJson()
        }
        let dataString:String = calcdata.merging(griddata, uniquingKeysWith: +).description
        var clipped:String = String(dataString[dataString.index(after: dataString.startIndex)..<dataString.index(before: dataString.endIndex)])
        if clipped == ":" { clipped = "" } //空対策
        //FIXME:jsでメソッド定義して呼ぶようにする
        return String(format: """
        document.getElementById('recordsCountText').innerText = "";
        if (cal != undefined || cal != null) {
            cal = cal.destroy();
        }
        var cal = new CalHeatMap();
        cal.init({
            data: %@,
            itemSelector: "#cal-heatmap",
            domain: "month",
            subDomain: "x_day",
            cellSize: 40,
            subDomainTextFormat: "%%d",
            range: 1,
            displayLegend: false,
            domainLabelFormat: "%%Y-%%m",
            onClick: function(date, nb) { document.getElementById('recordsCountText').innerText = (nb === null ? "0" : nb) + " Records" }
        });
        """, "{\(clipped)}")
    }
}
