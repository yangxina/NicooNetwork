//
//  NicooAPIManagerInterceptorProtocol.swift
//  CloudLibrary
//
//  Created by NicooYang on 25/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import Foundation

public protocol NicooAPIManagerInterceptorProtocol: class {

    // MARK: - Optional functions

    func manager(_ manager: NicooBaseAPIManager, beforePerformSuccess response: NicooURLResponse) -> Bool
    func manager(_ manager: NicooBaseAPIManager, afterPerformSuccess response: NicooURLResponse)

    func manager(_ manager: NicooBaseAPIManager, beforePerformFail response: NicooURLResponse?) -> Bool
    func manager(_ manager: NicooBaseAPIManager, afterPerformFail response: NicooURLResponse?)

    func manager(_ manager: NicooBaseAPIManager, shouldCallAPI params: [String: Any]?) -> Bool
    func manager(_ manager: NicooBaseAPIManager, afterCallAPI params: [String: Any]?)
}

public extension NicooAPIManagerInterceptorProtocol {

    func manager(_ manager: NicooBaseAPIManager, beforePerformSuccess response: NicooURLResponse) -> Bool {
        return true
    }
    func manager(_ manager: NicooBaseAPIManager, afterPerformSuccess response: NicooURLResponse) {}

    func manager(_ manager: NicooBaseAPIManager, beforePerformFail response: NicooURLResponse?) -> Bool {
        return true
    }
    func manager(_ manager: NicooBaseAPIManager, afterPerformFail response: NicooURLResponse?) {}

    func manager(_ manager: NicooBaseAPIManager, shouldCallAPI params: [String: Any]?) -> Bool {
        return true
    }
    func manager(_ manager: NicooBaseAPIManager, afterCallAPI params: [String: Any]?) {}
}
