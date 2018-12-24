//
//  RootViewController.swift
//  nBack
//
//  Created by PT2051 on 2018/12/14.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import WebKit
import SVGKit
import fluid_slider
import CDAlertView

class RootViewController: UIViewController {

    @IBOutlet var polyWebView: WKWebView!
    @IBOutlet var numberGameButton: UIButton!
    @IBOutlet var gridGameButton: UIButton!
    @IBOutlet var nSlider: Slider!
    @IBOutlet var levellabel: UILabel!
    @IBAction func auaua(_ sender: UIButton) {
        let execJS: String = "init(\(Int.random(in: 0...9)), \(Int.random(in: 50...200)), 0x668db6);"
        polyWebView.evaluateJavaScript(execJS, completionHandler: { (object, error) -> Void in
        })
    }
    var levelN: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        polyWebView.navigationDelegate = self
        
        // webview設定
        let path: String = Bundle.main.path(forResource: "poly", ofType: "html")!
        let localHtmlUrl: URL = URL(fileURLWithPath: path, isDirectory: false)
        polyWebView.scrollView.bounces = false
        polyWebView.scrollView.isScrollEnabled = false
        polyWebView.isOpaque = false
        polyWebView.scrollView.backgroundColor = UIColor.clear
        polyWebView.layer.backgroundColor = UIColor.clear.cgColor
        polyWebView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
        
        setupGameButtons()
        setupSlider()
        levellabel.text = NSLocalizedString("root_levelIndicator", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        // まとめてメソッドきりだせそう
        let calcMaxLevel:Int = userDefaults.integer(forKey: "calcMaxLevel")
        if userDefaults.bool(forKey: "isCalcMaxLevelUpdated") {
            // アラート表示
            let alert = CDAlertView(title: NSLocalizedString("root_calcGameNewRecordTitle", comment: ""), message: String(format: NSLocalizedString("root_calcGameNewRecordMessage", comment: ""), calcMaxLevel), type: .success)
            let doneAction = CDAlertViewAction(title: "OK💪")
            alert.add(action: doneAction)
            alert.show()
            
            userDefaults.set(false, forKey: "isCalcMaxLevelUpdated")
        }
        
        let gridMaxLevel:Int = userDefaults.integer(forKey: "gridMaxLevel")
        if userDefaults.bool(forKey: "isGridMaxLevelUpdated") {
            
            let alert = CDAlertView(title: NSLocalizedString("root_gridGameNewRecordTitle", comment: ""), message: String(format: NSLocalizedString("root_gridGameNewRecordMessage", comment: ""), gridMaxLevel), type: .success)
            let doneAction = CDAlertViewAction(title: "OK😇")
            alert.add(action: doneAction)
            alert.show()
            
            userDefaults.set(false, forKey: "isGridMaxLevelUpdated")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "calcGameSegue" {
            let calcGameViewController: CalcGameViewController = segue.destination as! CalcGameViewController
            calcGameViewController.levelN = self.levelN
        } else if segue.identifier == "gridGameSegue" {
            let gridGameViewController: GridGameViewController = segue.destination as! GridGameViewController
            gridGameViewController.levelN = self.levelN
        }
    }
    
    private func setupSlider() {
        let maxNum = 9
        let minNum = 1
        let initNum = 1
        let labelTextAttributes: [NSAttributedString.Key : Any] = [.font: UIFont(name: "HiraginoSans-W3", size: 12)!, .foregroundColor: UIColor.lightGray]
        nSlider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 1
            formatter.maximumFractionDigits = 0
            let string = "\(Int(floor(Float(fraction) * Float(maxNum - minNum) + Float(minNum))))"
            return NSAttributedString(string: string, attributes: [.font: UIFont(name: "HiraginoSans-W6", size: 14)!, .foregroundColor: UIColor.Set.lightBase])
        }
        nSlider.isOpaque = false
        nSlider.backgroundColor = UIColor(white: 0, alpha: 0)
        nSlider.setMinimumLabelAttributedText(NSAttributedString(string: "Easy", attributes: labelTextAttributes))
        nSlider.setMaximumLabelAttributedText(NSAttributedString(string: "Hard", attributes: labelTextAttributes))
        nSlider.shadowOffset = CGSize(width: 0, height: 10)
        nSlider.shadowBlur = 5
        nSlider.fraction = CGFloat(Float(initNum - minNum) / Float(maxNum))
        //nSlider.shadowColor = UIColor(white: 0, alpha: 0.1)
        nSlider.contentViewColor = UIColor.Set.lightBase
        nSlider.valueViewColor = UIColor.darkGray
        nSlider.didBeginTracking = { [weak self] _ in
            self?.setLabelHidden(true, animated: true)
        }
        nSlider.didEndTracking = { [weak self] slider in
            let selectedN = Int(floor(Float(slider.fraction) * Float(maxNum - minNum) + Float(minNum)))
            self?.levelN = selectedN
            self?.setLabelHidden(false, animated: true)
        }
        
    }
    
    private func setLabelHidden(_ hidden: Bool, animated: Bool) {
        let animations = {
            self.levellabel.alpha = hidden ? 0 : 1
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }

    
    private func setupGameButtons() {
        // 計算ゲームボタン
        let buttonSize = numberGameButton.frame.size
        numberGameButton.dropShadow()
        numberGameButton.layer.cornerRadius = numberGameButton.frame.height / 8
        if let calcSVG = SVGKImage(named: "calc_icon.svg") {
        calcSVG.size = CGSize(width: buttonSize.width * 0.6, height: buttonSize.height * 0.6)
        numberGameButton.setImage(calcSVG.uiImage, for: .normal)
        }
    
        // グリッドゲームボタン
        gridGameButton.layer.cornerRadius = gridGameButton.frame.height / 8
        gridGameButton.dropShadow()
        if let gridSVG = SVGKImage(named: "grid_icon.svg") {
        gridSVG.size = CGSize(width: buttonSize.width * 0.6, height: buttonSize.height * 0.6)
        gridGameButton.setImage(gridSVG.uiImage, for: .normal)
        }
    }

}

extension RootViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let execJS: String = "init(4, 100, 0x668db6);"
        webView.evaluateJavaScript(execJS, completionHandler: { (object, error) -> Void in
            // jsの関数実行結果
            // js側で戻り値を返すこともできる
        })
    }
}
