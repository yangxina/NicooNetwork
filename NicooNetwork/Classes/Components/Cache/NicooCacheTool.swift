//
//  NicooCacheTool.swift
//  CloudLibrary
//
//  Created by NicooYang on 2/5/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import UIKit
import YYCache
import CommonCrypto

/**
 这是一个单列的模式缓存工具类，处理所有存储和获取缓存的逻辑。
 缓存流程图地址:https://www.processon.com/view/link/5902c6c1e4b0be5dbd006133

 - superClass: NSObject
 - classDesign: 单列模式
 - author: NicooYang
 */
class NicooCacheTool: NSObject {

    private var yycache: YYCache!
    static private let kCacheDirectoryName = "customerCacheDatas"
    static private let shareInstance = NicooCacheTool()

    // MARK: - Life cycle

    private override init() {
        super.init()
        self.yycache = YYCache(name: NicooCacheTool.kCacheDirectoryName)
        self.yycache.memoryCache.countLimit = NicooNetworkingConfigurationManager.shareInstance.memoryCacheCountLimit;
        self.yycache.diskCache.countLimit = NicooNetworkingConfigurationManager.shareInstance.diskCacheCountLimit;
    }


    // MARK: - Public Functions

    /**
     获取对应请求的缓存

     - parameter            url: GET http方法的url
     - parameter            parameters: url参数
     - parameter            refuseExpire: 拒绝超时处理，直接取缓存

     - returns:             nil: 代表没有对应的缓存或者缓存失效
     */
    class func getCacheData(_ url: String, params: [String: Any]?, refuseExpire: Bool) -> Data? {
        let key = self.generateKey(url, parameters: params)
        let instance = self.shareInstance
        if let cacheItem = instance.yycache.object(forKey: key) as? NicooCacheItem {
            if !self.isTimeExpired(cacheItem) || refuseExpire {
                return cacheItem.data
            }
        }
        return nil
    }

    /**
     缓存数据，注意这里的data是从alamofire里的response里拿到的，repsonse.result.value是response.data转换出来的

     - parameter            url: GET http方法的url
     - parameter            parameters: url参数
     - parameter            expireTime: 失效时间

     - returns:             no special returns
     */
    class func cache(_ url: String, parameters: [String: Any]?, data: Data?, expireTime: TimeInterval?) {
        if data == nil { return }
        let key = self.generateKey(url, parameters: parameters)
        let cacheItem = NicooCacheItem(key: key, data: data!, expireTime: expireTime)
        self.shareInstance.yycache.setObject(cacheItem, forKey: key)

        let cacheFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let path = cacheFolder! + "/\(kCacheDirectoryName)"
        print(path)
    }

    /**
     清除缓存
     */
    class func releaseCache() {
        DispatchQueue.main.async {
            self.shareInstance.yycache.removeAllObjects()
        }
    }


    // MARK: - Private Functions
    
    /**
     通过url和参数拼接成key，并且key需要要经过base64编码
     
     - parameter            url: http方法的url
     - parameter            parameters: url参数
     
     - returns:             返回生成的key
     */
    fileprivate class func generateKey(_ url: String, parameters: [String: Any]?) -> String {
        var key = url
        if let para = parameters {
            if para.count > 0 {
                key.append("?")
                for aKey in para.keys {
                    key.append("aKey=\(para["\(aKey)"]!)&")
                }
                key = String(key[..<key.index(key.endIndex, offsetBy: -1)])
            }
        }
        return key.md5()
    }



    /**
     判断对应的缓存是否失效

     - parameter            key: url与parameters生成的key

     - returns:             true: 缓存失效
     */
    fileprivate class func isTimeExpired(_ cache: NicooCacheItem) -> Bool {
        let currentTime = CACurrentMediaTime()
        // 不知道为什么，有一个手机出现了currentTime比cache.storeTime还小，然后就一直读取的缓存
        let timeOffset = currentTime - cache.storeTime.doubleValue
        return ((timeOffset > cache.expireTime) || (timeOffset < 0))
    }


}

extension String {
    
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
}
