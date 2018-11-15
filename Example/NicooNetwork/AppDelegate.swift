//
//  AppDelegate.swift
//  NicooNetworkDemo
//
//  Created by NicooYang on 2018/11/5.
//  Copyright © 2018年 tzpt. All rights reserved.
//


import UIKit
import NicooNetwork
@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        findServer()
        return true
    }
    
    private func findServer() {
        // service 配置
        NicooServiceFactory.shareInstance.dataSource = self
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

// MARK: - NicooServiceFactoryProtocol
extension AppDelegate: NicooServiceFactoryProtocol {
    
    /// 自定义的服务
    ///
    /// - Returns: 自定义的服务名
    func servicesKindsOfServiceFactory() -> [String : String] {
        return [ConstValue.kYTSGService: "YTSGService"]
    }
    
    /// 自定义的服务所在的命名空间 （如果自定义的服务是组件，命名空间就为 服务组件名）
    ///
    /// - Parameter service: 服务名
    /// - Returns: m命名空间
    func namespaceForService(_ service: String) -> String? {
        switch service {
        case ConstValue.kYTSGService:
            return "NicooNetwork_Example"   // 这里可能会由于NicooNetwork-Example 中的 特殊符号导致找不到Servicee的命名空间
        default:
            return nil
        }
    }
}


