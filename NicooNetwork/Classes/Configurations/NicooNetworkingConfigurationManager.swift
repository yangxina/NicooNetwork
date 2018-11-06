//
//  NicooNetworkingConfigurationManager.swift
//  CloudLibrary
//
//  Created by NicooYang on 25/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import UIKit

open class NicooNetworkingConfigurationManager: NSObject {

    public var isReachable: Bool {
        return NicooNetworkManager.isNetworkAvailable()
    }
    private(set) var shouldCache: Bool = true
    private(set) var apiNetworkingTimeoutSeconds: TimeInterval = 15
    private(set) var cacheOutdateSeconds: TimeInterval = 10
    private(set) var diskCacheCountLimit: UInt = 500
    private(set) var memoryCacheCountLimit: UInt = 200
    /// 参数放到body
    private(set) var shouldSetParamsInHTTPBodyButGET: Bool = false
    private(set) var shouldLoadCacheDataWhileNoNetwork: Bool = false
    private(set) public static var shareInstance: NicooNetworkingConfigurationManager = NicooNetworkingConfigurationManager()

    private override init() {
        super.init()
        NicooNetworkManager.startObservingNetwork()
    }
}

