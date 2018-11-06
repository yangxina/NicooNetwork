//
//  NicooAPIManagerProtocol.swift
//  CloudLibrary
//
//  Created by NicooYang on 21/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import Foundation

/*
 CTAPIBaseManager的派生类必须符合这些protocal
 */
public protocol NicooAPIManagerProtocol: class {

    func methodName() -> String
    func serviceType() -> String
    func requestType() -> NicooAPIManagerRequestType
    func shouldCache() -> Bool

    // the optional method may used for pageable API manager
    func cleanData()
    func reform(_ params: [String: Any]?) -> [String: Any]?
    /// 注意：alamofire只支持get\head\delete将参数拼接到url后面
    func parameterEncodingType() -> NicooAPIManagerParameterEncodeing
}

public extension NicooAPIManagerProtocol where Self: NicooBaseAPIManager {

    func cleanData() {}
    func reform(_ params: [String: Any]?) -> [String: Any]? {
        return params
    }
    func parameterEncodingType() -> NicooAPIManagerParameterEncodeing {
        return .json
    }

}
