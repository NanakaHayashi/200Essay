//
//  AppDelegate.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/23.
//  Copyright © 2020 nanakahayashi. All rights reserved.
// ブロック機能あり

import UIKit
import NCMB
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //NCMBの登録
        NCMB.setApplicationKey("5445d7f049d199a9618e4407e0cd5f197806b68315853f88befec5c253342e03", clientKey: "9274c4153232c404fed9ea558ea099a10ed434c76c52383e0c24bfc8ed35b0d0")
        
        
        IQKeyboardManager.shared.enable = true
        
        

        return true
        
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

