//
//  NicooAPIManagerDataReformProtocol.swift
//  CloudLibrary
//
//  Created by NicooYang on 21/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import Foundation

public protocol NicooAPIManagerDataReformProtocol: class {
    func manager(_ manager: NicooBaseAPIManager, reformData jsonData: Data?) -> Any?
    func manager(_ manager: NicooBaseAPIManager, reformData data: [String: Any]?) -> Any?
    func manager(_ manager: NicooBaseAPIManager, faildToReform data: [String: Any]?) -> Any?
}

public extension NicooAPIManagerDataReformProtocol {
    func manager(_ manager: NicooBaseAPIManager, reformData jsonData: Data?) -> Any? { return nil }
    func manager(_ manager: NicooBaseAPIManager, reformData data: [String: Any]?) -> Any? { return nil }
    func manager(_ manager: NicooBaseAPIManager, faildToReform data: [String: Any]?) -> Any? { return nil }
}
