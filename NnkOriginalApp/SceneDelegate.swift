//
//  SceneDelegate.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/23.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    
    


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
   
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let ud = UserDefaults.standard
            //ログインしているかどうかを取り出す
            let isLogin = ud.bool(forKey: "isLogin")
            let window = UIWindow(windowScene: scene as! UIWindowScene)
        
            if isLogin == true {
                //Main.storyboardの取得
                let storyboard = UIStoryboard(name: "Main", bundle:Bundle.main)
                //一番最初の画面の指定
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                //rootVCに上の変数を代入
                self.window?.rootViewController = rootViewController
              
                self.window?.backgroundColor = UIColor.white
                //画面表示
                self.window?.makeKeyAndVisible()
                
            }else{
                let storyboard = UIStoryboard(name: "Signin", bundle:Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                self.window?.rootViewController = rootViewController
                self.window?.backgroundColor = UIColor.white
                self.window?.makeKeyAndVisible()
            }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
  
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    
    }

    func sceneWillResignActive(_ scene: UIScene) {
 
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
      
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
     
    }


}

