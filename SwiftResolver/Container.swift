//
//  Container.swift
//  SwiftResolver
//
//  Created by Kyle LeNeau on 7/10/16.
//  Copyright © 2016 Kyle LeNeau. All rights reserved.
//

import Foundation

public protocol ResolverType {
    func resolve<Service>(serviceType: Service.Type) -> Service?
    func resolve<Service>(serviceType: Service.Type, name: String?) -> Service?
}

public final class Container {
    // Registered services end up here
    private var services = [ServiceKey: ServiceEntryType]()
    
    public init(registeringClosure: Container -> Void) {
        registeringClosure(self)
    }
    
    // Register a service into the container to be resolved when needed
    public func register<Service>(
        serviceType: Service.Type,
        name: String? = nil,
        factory: ResolverType -> Service) -> ServiceEntry<Service> {
        
        let key = ServiceKey(factoryType: factory.dynamicType, name: name)
        let entry = ServiceEntry(serviceType: serviceType, factory: factory)
        services[key] = entry
        return entry
    }
    
    public func removeAll() {
        services.removeAll()
    }
}

extension Container: CustomStringConvertible {
    public var description: String {
        return "["
            + services.map { "\n    { \($1.describeWithKey($0)) }"}.sort().joinWithSeparator(",")
        + "\n]"
    }
}

extension Container: ResolverType {
    
    // Resolve just a service by type
    public func resolve<Service>(serviceType: Service.Type) -> Service? {
        return resolve(serviceType, name: nil)
    }
    
    // Resolve a service by type and name
    public func resolve<Service>(serviceType: Service.Type, name: String?) -> Service? {
        typealias FactoryType = ResolverType -> Service
        return resolve(name: name) { (factory: FactoryType) in factory(self) }
    }
    
    // Resolve and create the instance of the class registered
    private func resolve<Service, Factory>(name name: String?, invoker: Factory -> Service) -> Service? {
        var resolvedInstance: Service?
        let key = ServiceKey(factoryType: Factory.self, name: name)
        if let entry = getEntry(key) as ServiceEntry<Service>? {
            resolvedInstance = resolveEntry(entry, key: key, invoker: invoker)
        }
        
        return resolvedInstance
    }
    
    // Look up and entry in the array
    private func getEntry<Service>(key: ServiceKey) -> ServiceEntry<Service>? {
        let entry = services[key] as? ServiceEntry<Service>
        return entry
    }
    
    // Actually create the instance registered
    private func resolveEntry<Service, Factory>(entry: ServiceEntry<Service>, key: ServiceKey, invoker: Factory -> Service) -> Service {
        let resolvedInstance = invoker(entry.factory as! Factory)
        return resolvedInstance
    }
}