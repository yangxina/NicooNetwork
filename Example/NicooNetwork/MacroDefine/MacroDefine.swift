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
    
}

// MARK: - User Defaults keys

public extension UserDefaults {
    
    enum Keys {
        //static let KeyName = "xxxxx"
    }
    
}

// MARK: - 全局静态常量

public struct ConstValue {
    public static let kScreenHeight = UIScreen.main.bounds.size.height
    public static let kScreenWdith = UIScreen.main.bounds.size.width

    #if DEVELOPMENT
    public static let kCLBaseUrlString = "http://119.23.205.178:8077"
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
   
}

// MARK: - Function

// log
public func NicooLog(_ item: Any, _ file: String = #file,  _ line: Int = #line, _ function: String = #function) {
    #if DEBUG
    print(file + ":\(line):" + function, item)
    #endif
}

public struct CLAlertMessages {
    
    // MARK: - 全局
    
    public static let kNetworkErrorMessage = "网络请求失败!"
    public static let kRequestFailedUnknownError = "数据错误!"
    public static let kSearchEmptyData = "发现0条数据!"
    public static let kBeenKickedOutAlertMsg = "账号已在其它设备登录，请确认是否本人操作！"
    /* 相机 */
    public static let kAllowCamera = "请在iPhone的“设置－隐私－相机”选项中，允许云书屋访问您的相机。"
    /* 相册 */
    public static let kAllowPhoto = "请在iPhone的“设置－隐私－照片”选项中，允许云书屋访问您的照片。"
    /* 分享 */
    public static let kHaveNotInstallWechat = "未安装微信客户端!"
    public static let kHaveNotInstallQQ = "未安装QQ客户端!"
    public static let kHaveNotinstallSina = "未安装新浪微博客户端!"
    public static let kShareFail = "分享失败!"
    public static let kVideoPlayNetworkMessage = "当前为非wifi环境，播放将产生流量费用，是否继续?"
    
}
