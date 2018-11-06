//
//  NicooService.swift
//  CloudLibrary
//
//  Created by NicooYang on 24/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import UIKit

/** 
 所有TZService的派生类都要符合这个protocol
 */
public protocol NicooServiceProtocol: class {
    /// 标记是否是生产环境
    var isProductionEnvironment: Bool { get }

    /// 生产环境API base url
    var productionAPIBaseURL: String { get }
    /// 开发环境API base url
    var developmentAPIBaseURL: String { get }

    /// 生产环境API版本
    var productionAPIVersion: String { get }
    /// 开发环境API版本
    var developmentAPIVersion: String { get }

    /// 生产环境公钥
    var productionPublicKey: String { get }
    /// 开发环境公钥
    var developmentPublicKey: String { get }

    /// 生产环境私钥
    var productionPrivateKey: String { get }
    /// 开发环境私钥
    var developmentPrivateKey: String { get }

    // MARK: - Optional functions

    /// 为某些Service需要拼凑额外字段到URL处
    func extraParams() -> [String: Any]?
    /// 为某些Service需要拼凑额外的HTTPToken，如accessToken
    func extraHttpHeadParams(_ methodName: String) -> [String: String]?
    func urlGeneratingRule(_ methodName: String) -> String
    /// 提供拦截器集中处理Service错误问题，比如token失效要抛通知
    func shouldCallBackByFailedOnCallingAPI(_ response: NicooURLResponse?) -> Bool
    /// 如果拦截器获取到的是token失效，那就返回true
    func isTokenError() -> Bool
}

public extension NicooServiceProtocol where Self: NicooService {
    func extraParams() -> [String: Any]? { return nil }
    func extraHttpHeadParams(_ methodName: String) -> [String: Any]? { return nil }
    func shouldCallBackByFailedOnCallingAPI(_ response: NicooURLResponse) -> Bool { return true }
    func isTokenError() -> Bool { return false }
}

open class NicooService: NSObject {

    public var publicKey: String? {
        return (self.child == nil || self.child!.isProductionEnvironment) ? self.child?.productionPublicKey : self.child?.developmentPublicKey
    }
    public var privateKey: String? {
        return (self.child == nil || self.child!.isProductionEnvironment) ? self.child?.productionPrivateKey : self.child?.developmentPrivateKey
    }
    public var apiBaseURL: String? {
        return (self.child == nil || self.child!.isProductionEnvironment) ? self.child?.productionAPIBaseURL : self.child?.developmentAPIBaseURL
    }
    public var apiVersion: String? {
        return (self.child == nil || self.child!.isProductionEnvironment) ? self.child?.productionAPIVersion : self.child?.developmentAPIVersion
    }
    public private(set) weak var child: NicooServiceProtocol?
    public var tokenError: Bool = false


    // Mark: - Life cycle

    required override public init() {
        super.init()
        if self is NicooServiceProtocol {
            self.child = self as? NicooServiceProtocol
        }
    }

    // MARK: - Public functions

    /**
     根据apiname生成url字符串,如果有版本号，版本号默认紧随baseurl后

     - parameter            apiMethodName: api名

     - returns:             拼接后的url字符串
     */
    open func urlGeneratingRule(_ apiMethodName: String) -> String {
        if self.apiVersion == nil || self.apiVersion!.isEmpty {
            return String(format: "%@/%@", self.apiBaseURL ?? "", apiMethodName)
        }
        return String(format: "%@/%@/%@", self.apiBaseURL ?? "", self.apiVersion!, apiMethodName)
    }

}
