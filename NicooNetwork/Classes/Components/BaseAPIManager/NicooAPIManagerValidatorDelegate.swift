//
//  NicooAPIManagerValidatorProtocol.swift
//  CloudLibrary
//
//  Created by NicooYang on 21/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import Foundation

public protocol NicooAPIManagerValidatorDelegate: class {
    func manager(_ manager: NicooBaseAPIManager, isCorrectWithCallbackData data: [String: Any]?) -> Bool
    func manager(_ manager: NicooBaseAPIManager, isCorrectWithParams params: [String: Any]?) -> Bool
}
