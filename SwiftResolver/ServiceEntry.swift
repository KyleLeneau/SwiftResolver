//
//  ServiceEntry.swift
//  SwiftResolver
//
//  Created by Kyle LeNeau on 7/10/16.
//  Copyright © 2016 Kyle LeNeau. All rights reserved.
//

import Foundation

internal typealias FunctionType = Any

// Ablility to use this as a type in the Array of services
internal protocol ServiceEntryType: Any {
    func describeWithKey(_ serviceKey: ServiceKey) -> String
}

// Represents and entry in the registered services
public final class ServiceEntry<Service> {
    fileprivate let serviceType: Service.Type
    internal let factory: FunctionType
    
    internal init(serviceType: Service.Type, factory: FunctionType) {
        self.serviceType = serviceType
        self.factory = factory
    }
}

extension ServiceEntry: ServiceEntryType {
    // Helper to print the type registered
    internal func describeWithKey(_ serviceKey: ServiceKey) -> String {
        let nameDescription = serviceKey.name.map { ", Name: \"\($0)\"" } ?? ""
        return "Service: \(serviceType)"
            + nameDescription
            + ", Factory: \(type(of: (factory) as AnyObject))"
    }
}

// Unique key to represent what's registered in the container
internal struct ServiceKey {
    internal let factoryType: FunctionType.Type
    internal let name: String?
    
    internal init(factoryType: FunctionType.Type, name: String? = nil) {
        self.factoryType = factoryType
        self.name = name
    }
}

extension ServiceKey: Hashable {
    var hashValue: Int {
        return String(describing: factoryType).hashValue ^ (name?.hashValue ?? 0)
    }
}

func == (lhs: ServiceKey, rhs: ServiceKey) -> Bool {
    return lhs.factoryType == rhs.factoryType && lhs.name == rhs.name
}
