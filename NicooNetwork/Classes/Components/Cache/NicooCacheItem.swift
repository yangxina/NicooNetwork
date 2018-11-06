//
//  NicooCacheItem.swift
//  CloudLibrary
//
//  Created by NicooYang on 3/5/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import UIKit

/**
 这是缓存的数据模型，包涵对应的key，存储时间以及开始时间

 - superClass: NSObject
 - classDesign: no specila Design pattern
 - author: TyroneZhang
 */
class NicooCacheItem: NSObject, NSCoding {

    static fileprivate let kDefaultExpireTime: Double = 10.0

    var key: String!
    var storeTime: NSNumber!
    var data: Data!
    var expireTime: Double = kDefaultExpireTime

    init(key: String, data: Data, expireTime: TimeInterval?) {
        self.key = key
        self.data = data
        if let time = expireTime {
            self.expireTime = time
        }
        self.storeTime = NSNumber(value: CACurrentMediaTime())
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(key, forKey: "key")
        aCoder.encode(storeTime, forKey: "storeTime")
        aCoder.encode(data, forKey: "data")
        aCoder.encode(expireTime, forKey: "expireTime")
    }

    required init?(coder aDecoder: NSCoder) {
       
        if let key = aDecoder.decodeObject(forKey: "key") as? String {
             self.key = key
        }
        if let num = aDecoder.decodeObject(forKey: "storeTime") as? NSNumber {
            self.storeTime = num
        } else {
            self.storeTime = 10
        }
        self.data = aDecoder.decodeObject(forKey: "data") as? Data
        self.expireTime = aDecoder.decodeDouble(forKey: "expireTime")
    }
}
