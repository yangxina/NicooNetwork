//
//  YTSGBaseAPI.swift
//  CloudLibrary
//
//  Created by NicooYang on 10/04/2018.
//  Copyright © 2018 TZPT. All rights reserved.
//

import UIKit
import NicooNetwork
/**
 整个app网络请求的base类，用于做一些公共处理
 */
open class YTSGBaseAPI: NicooBaseAPIManager, NicooAPIManagerProtocol, NicooAPIManagerValidatorDelegate, NicooAPIManagerInterceptorProtocol {
    
    public override init() {
        super.init()
        interceptor = self
        validator = self
    }
    
    // MAKR: - NicooAPIManagerProtocol
    
   open func methodName() -> String {
        return ""
    }
    
   open func serviceType() -> String {
        return ConstValue.kYTSGService
    }
    
   open func requestType() -> NicooAPIManagerRequestType {
        return .get
    }
    
   open func shouldCache() -> Bool {
        return false
    }
    
    
   open func reform(_ params: [String: Any]?) -> [String: Any]? {
        return params
    }
    
    open func cleanData() {
        
    }
  
   open func parameterEncodingType() -> NicooAPIManagerParameterEncodeing {
        return .json
    }
    
    // MARK: - NicooAPIManagerValidatorDelegate
    
    // 在这里验证参数是否错误，并且给出具体的错误原因
   open func manager(_ manager: NicooBaseAPIManager, isCorrectWithParams params: [String: Any]?) -> Bool {
        return true
    }
    
   open func manager(_ manager: NicooBaseAPIManager, isCorrectWithCallbackData data: [String: Any]?) -> Bool {
        if (data?["status"] as? NSNumber)?.intValue == 200 {
            return true
        }
        return false
    }
    
    // MARK: - NicooAPIManagerInterceptorProtocol
    
   open func manager(_ manager: NicooBaseAPIManager, beforePerformSuccess response: NicooURLResponse) -> Bool {
        return true
    }
   open func manager(_ manager: NicooBaseAPIManager, afterPerformSuccess response: NicooURLResponse) {}
    
    // 在这里根据错误类型，给errorMessage赋值
   open func manager(_ manager: NicooBaseAPIManager, beforePerformFail response: NicooURLResponse?) -> Bool {
        if manager.errorType == .noNetwork {
            self.errorMessage = CLAlertMessages.kNetworkErrorMessage
        } else if manager.errorType == .defaultError {
            self.errorMessage = CLAlertMessages.kNetworkErrorMessage
        } else if manager.errorType == .timeout {
            self.errorMessage = CLAlertMessages.kNetworkErrorMessage
        }
        return true
    }
   open func manager(_ manager: NicooBaseAPIManager, afterPerformFail response: NicooURLResponse?) {}
    
   open func manager(_ manager: NicooBaseAPIManager, shouldCallAPI params: [String: Any]?) -> Bool {
        return true
    }
   open func manager(_ manager: NicooBaseAPIManager, afterCallAPI params: [String: Any]?) {}
    
}


