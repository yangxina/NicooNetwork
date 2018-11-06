//
//  CodableUtil.swift
//  CloudLibrary
//
//  Created by Jiexiang on 2018/5/7.
//  Copyright © 2018年 TZPT. All rights reserved.
//

/**
 用于解析JSON的全局方法
 
 - superclass: 无
 - classdesign: 无
 - author: JX
 */

import Foundation

public func decode<T>(response: Data?, of: T.Type) throws -> T? where T: Codable {
    guard let response = response else { return nil }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970
    do {
        let model = try decoder.decode(T.self, from: response)
        return model
    } catch {
        NicooLog("解析JSON出错: \(error)")
        return nil
    }
}

public struct ObjectResponse<T: Codable>: Codable {
   public let data: T?
}
