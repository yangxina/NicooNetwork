//
//  MacroDefine.swift
//  CloudLibrarySwift
//
//  Created by Zhangyao on 13/1/2016.
//  Copyright © 2016 TZPT. All rights reserved.
//

import UIKit

// MARK: - AppKey

public enum APPKeys {
    /// WeChat APPid
    #if DEVELOPMENT
    public static let kWeChatAppId = "wxbf71708d20976b86"
    #else
    public static let kWeChatAppId = "wx7490260081085f6b"
    #endif
    /// 支付宝appid
    public static let kAlipayAppId = "2017121900974273"
    /// QQ appid
    public static let kQQAppId = "1105405811"
    /// 高的地图appid
    #if DEVELOPMENT
    public static let kAMAppKey = "b92482ab31952077363e510a8a1fa9ca"
    #else
    public static let kAMAppKey = "675dbf1aee5765233ff3978aa1582e9a"
    #endif
    /// 友盟
    public static let kUMengAppKey = "58b4e1433eae2520670003f4"
    public static let kUMengChannelId = "App Store"
    /// sina
    public static let kSinaAppkey = "73772033"
    public static let kSinaAppSecurity = "424a9c7fb70713f36568ffe8699cebdf"
}

// MARK: - User Defaults keys

public extension UserDefaults {
    
    enum Keys {
        //static let KeyName = "xxxxx"
    }
    
}

// MARK: - 全局静态常量

public struct ConstValue {
    /// 本appurlscheme
    #if DEVELOPMENT
    public static let kCLMAppScheme = "ytsg10"
    #else
    public static let kCLMAppScheme = "ytsg"
    #endif
    public static let kScreenHeight = UIScreen.main.bounds.size.height
    public static let kScreenWdith = UIScreen.main.bounds.size.width
    public static let kReadingFromBookShelfEventId = "readingFromBookShelf"
    public static let kDefaultFontName = "PingFangSC-Light"
    public static let kDefaultTableSeparatorColor = "#F4F4F4"
    #if DEVELOPMENT
    public static let kCLBaseUrlString = "http://119.23.205.178:8077"
    //    static let kCLBaseUrlString = "http://192.168.28.10:18081"
    #else
    public static let kCLBaseUrlString = "http://m.ytsg.cn" // 基础地址
    #endif
    // image base url
    public static let kImageURL = "http://img.ytsg.cn/" // 图片
    // ServiceIdentifier
    public static let kYTSGService = "kYTSGService"
    public static let kTestService = "kTestService"
}

// MARK: - Notificaiton name

public extension Notification.Name {
    /// 登录成功的通知
    static let kUserLoginSuccessfully = Notification.Name("kUserLoginSuccessfully")
    /// 在切换定位信息后，需要某些地方收到通知，并重新获取数据
    static let kLocationHaveSwitchedNotification = Notification.Name("locationHaveSwitchedNotification")
    /// 账户信息变动的通知
    static let kUserBasicalInformationChanged = Notification.Name("kUserBasicalInformationChanged")
    /// 用户别踢下线或者token失效的回调
    static let kUserBeenKickedOutNotification = Notification.Name("kUserBeenKickedOutNotification")
    /// 微信回调结果成功
    static let kWechatReturnWithSuccessNotificaiton = Notification.Name("wechatReturnSuccess")
    /// 微信回调结果失败
    static let kWechatReturnWithFailureNotification = Notification.Name("wechatReturnFailure")
    /// 支付宝支付成功
    static let kAlipayReturnWithSuccessNotification = Notification.Name("alipayReturnSuccess")
    /// 支付宝支付失败
    static let kAlipayReturnWithFailureNotification = Notification.Name("alipayReturnFailure")
    /// 支付宝授权失败
    static let kAlipayReturnWithAuthorizationFail = Notification.Name("alipayAuthorizationFail")
    /// 逾期消息提醒通知
    static let kOverdueBookMsgReminder = Notification.Name("OverdueMsgReminder")
}

// MARK: - Function

// log
public func NicooLog(_ item: Any, _ file: String = #file,  _ line: Int = #line, _ function: String = #function) {
    #if DEBUG
    print(file + ":\(line):" + function, item)
    #endif
}
