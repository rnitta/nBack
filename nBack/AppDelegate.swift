//
//  AppDelegate.swift
//  nBack
//
//  Created by PT2051 on 2018/12/14.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // スリープ無効
        UIApplication.shared.isIdleTimerDisabled = true
        
        
        // チュートリアルスキップ
        let isTutorialSkipped: Bool = UserDefaults.standard.bool(forKey: "isTutorialSkipped")
        if isTutorialSkipped {
            let RVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootView") as! RootViewController
            self.window?.rootViewController = RVC
        }else{
            // implement register view controller
            let TVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialView") as! TutorialViewController
            self.window?.rootViewController = TVC
        }
        self.window?.makeKeyAndVisible()
        
        // アナリティクス
        FirebaseApp.configure()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let userDefault = UserDefaults()
        let udnotificationKey: String = "isDailyLocalNotificationEnabled"
        if userDefault.bool(forKey: udnotificationKey) {
            //ローカル通知
            let trigger: UNNotificationTrigger
            let content = UNMutableNotificationContent()
            var notificationTime = DateComponents()
            
            notificationTime.hour = 9
            notificationTime.minute = 00
            trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: true)
            
            content.title = "nBackTrainer"
            let localNotificationBodyKey = String(format: "localNotificationBodyKey%d", Int.random(in: 1...4))
            content.body = NSLocalizedString(localNotificationBodyKey, comment: "")
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

