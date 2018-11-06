//
//  NicooNetworkManager.swift
//  CloudLibrary
//
//  Created by NicooYang on 26/6/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import UIKit
import Alamofire

public enum NicooNetworkType {
    case notReachable
    case wifi
    case wwan
    case unKnown
}

public extension NSNotification.Name {
    
    static let kRealReachabilityStatusChanged = Notification.Name("kRealReachabilityStatusChanged")
}

open class NicooNetworkManager: NSObject {
    private static let instance: NicooNetworkManager = NicooNetworkManager()
    private static var haveAddNotificaton = false
    private var networkStatus: Bool = true
    private let host = "www.baidu.com"
    private var networkManager: NetworkReachabilityManager!
    private var networkType: NicooNetworkType = .unKnown

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private override init() {
        super.init()
    }

    class func isNetworkAvailable() -> Bool {
        return instance.networkStatus
    }

    public class func currentNetworkType() -> NicooNetworkType {
        return instance.networkType
    }

    class func startObservingNetwork() {

        if !haveAddNotificaton {
            haveAddNotificaton = true
            NotificationCenter.default.addObserver(self, selector: #selector(NicooNetworkManager.reObservingNetwork), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        instance.networkManager = NetworkReachabilityManager(host: instance.host)
        if !instance.networkManager.isReachable {
            instance.networkStatus = false
            
        }
        instance.networkManager.listener = { status in
            switch status {
            case .notReachable:
                instance.networkStatus = false
                instance.networkType = .notReachable
            case .unknown:
                instance.networkStatus = true
                instance.networkType = .unKnown
            case .reachable(.ethernetOrWiFi):
                instance.networkStatus = true
                instance.networkType = .wifi
            case .reachable(.wwan):
                instance.networkStatus = true
                instance.networkType = .wwan
            }
            NotificationCenter.default.post(name: NSNotification.Name.kRealReachabilityStatusChanged, object: nil)
        }
        instance.networkManager.startListening()
    }

    @objc class private func reObservingNetwork() {
        instance.networkManager.stopListening()
        instance.networkStatus = instance.networkManager.isReachable
        instance.networkManager.startListening()
    }

}
