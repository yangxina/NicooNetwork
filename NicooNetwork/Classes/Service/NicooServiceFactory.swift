//
//  NicooServiceFactory.swift
//  CloudLibrary
//
//  Created by NicooYang on 24/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import Foundation

public protocol NicooServiceFactoryProtocol: class {

    /**
     获取app中存在的service对应的dictionary，一个app有可能会有几个域名，所以就有可能存在几个service。
     存储的key为service的Identifier,其实就是一个自命名的字符串
     存储的value为对应的dervice类的类名。

     - returns:             dictionary: app中所有用到的service类名
     */
    func servicesKindsOfServiceFactory() -> [String: String]
    func namespaceForService(_ service: String) -> String?
}

open class NicooServiceFactory: NSObject {

    open weak var dataSource: NicooServiceFactoryProtocol?
    public static let shareInstance: NicooServiceFactory = NicooServiceFactory()
    private lazy var services: [String: NicooService] = {
        return [String: NicooService]()
    }()

    // MARK: - Life cycle

    private override init() {
        super.init()
    }

    // MARK: - Public functions

    func serviceWith(_ identifier: String) -> NicooServiceProtocol {
        assert(self.dataSource != nil, "必须提供dataSource绑定并实现servicesKindsOfServiceFactory方法，否则无法正常使用Service模块")
        DispatchQueue(label: "com.serviceFactory.serialQueue").sync {
            if self.services[identifier] == nil {
                self.services[identifier] = self.newServiceWith(identifier)
            }
        }
        return self.services[identifier]! as! NicooServiceProtocol
    }

    private func newServiceWith(_ identifier: String) -> NicooService {
        let dict = self.dataSource!.servicesKindsOfServiceFactory()
        assert(dict.count != 0, "无法创建service，请检查servicesKindsOfServiceFactory提供的数据是否正确")
        let serviceClassName = dict[identifier]
        assert(serviceClassName != nil, "无法创建service，请检查servicesKindsOfServiceFactory提供的数据是否正确")
        let namespace = dataSource!.namespaceForService(identifier)
        assert(namespace != nil, "未指定service对应的namespace")
        let serviceClass = self.getClass(serviceClassName!, namespace!) as? NicooService.Type
        assert(serviceClass != nil, "你提供的Service不是NicooService的子类")
        let service = serviceClass!.init()
        assert(service is NicooServiceProtocol, "你提供的Service没有遵循CTServiceProtocol")
        return service
    }

    /**
     swift不能直接向oc一样运用classname转换为class，需要加入命名空间才行
     eg.
     let instance = (anyClass as! ViewController.Type).init()

     - parameter            className: 需要获取的class的类名

     - returns:             AnyClass: 类对象
     */
    private func getClass(_ className: String,_ namespace: String) -> AnyClass? {
        let aNamespace = namespace.replacingOccurrences(of: " ", with: "_")
        let anyClass: AnyClass? = NSClassFromString("\(aNamespace).\(className)")
        return anyClass
    }
}
