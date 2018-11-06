//
//  NicooURLResponse.swift
//  CloudLibrary
//
//  Created by NicooYang on 23/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import UIKit
import Alamofire

enum NicooURLResponseStatus {
    case success
    case timeout
    case networkError // 除了超时以外的错误都是网络故障
}

open class NicooURLResponse: NSObject {

    var requestParams: [String: Any]?
    private(set) var status: NicooURLResponseStatus = .success
    private(set) var contentString: String? = nil
    public private(set) var content: Any? = nil
    private(set) var requestId: NSInteger = 0
    private(set) var request: URLRequest?  = nil
    private(set) var responseData: Data? = nil
    private(set) var error: NSError? = nil
    private(set) var isCache: Bool = false


    private override init() {
        super.init()
    }

    convenience init(_ responseString: String?, requestId: Int, request: URLRequest, requestParams: [String: Any]?, responseData: Data?, status: NicooURLResponseStatus) {
        self.init()
        self.contentString = responseString
        if let data = responseData {
            do {
                self.content = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            } catch {}
        }
        self.requestId = requestId
        self.request = request
        self.responseData = responseData
        self.requestParams = requestParams
        self.status = status
    }

    convenience init(_ responseString: String?, requestId: Int, request: URLRequest, requestParams: [String: Any]?, responseData: Data?, error: NSError) {
        self.init()
        self.contentString = responseString ?? ""
        if let data = responseData {
            do {
                self.content = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            } catch {}
        }
        self.status = self.responseStatus(error)
        self.requestId = requestId
        self.request = request
        self.responseData = responseData
        self.requestParams = requestParams
        self.error = error
    }

    /**
     在读取缓存的时候，拿读出来的数据生成response，将isCache赋值为true，代表该response是缓存

     - parameter            data: 缓存的data数据

     - returns:             缓存数据生成的response
     */
    convenience init(_ data: Data) {
        self.init()
        self.contentString = String(data: data, encoding: String.Encoding.utf8)
        self.responseData = data
        if let data = responseData {
            do {
                self.content = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            } catch {}
        }
        self.isCache = true
    }

    // MARK: - Private function

    private func responseStatus(_ error: NSError?) -> NicooURLResponseStatus {
        if let error = error {
            if error.code == NSURLErrorTimedOut {
                return .timeout
            }
            return .networkError
        }
        return .success
    }

}
