//
//  SwiftResolverTests.swift
//  SwiftResolverTests
//
//  Created by Kyle LeNeau on 7/10/16.
//  Copyright © 2016 Kyle LeNeau. All rights reserved.
//

import XCTest
@testable import SwiftResolver

protocol Walkable {
    func numberOfLimbs() -> Int
}

class Bird: Walkable {
    func numberOfLimbs() -> Int {
        return 2
    }
}

class AtAt: Walkable {
    let pilot: Pilot
    
    init(pilot: Pilot) {
        self.pilot = pilot
    }
    
    func numberOfLimbs() -> Int {
        return 4
    }
}

protocol Pilot {
    func name() -> String
}

class AtAtPilot: Pilot {
    func name() -> String {
        return "Joe"
    }
}

class SwiftResolverTests: XCTestCase {
    
    func testContainerShouldRegisterBasicType() {
        let container = Container() { container in
            container.register(Walkable.self) { _ in
                Bird()
            }
        }

        XCTAssertNotNil(container)
        
        let type = container.resolve(Walkable.self)
        XCTAssertNotNil(type)
        XCTAssertTrue(type is Bird)
        XCTAssertTrue(type?.numberOfLimbs() == 2)
    }
    
    func testContainerShouldRegisterConnectedTypes() {
        let container = Container() { container in
            container.register(Walkable.self) { resolver in
                AtAt(pilot: resolver.resolve(Pilot.self)!)
            }
            container.register(Pilot.self) { _ in
                AtAtPilot()
            }
        }
        
        XCTAssertNotNil(container)
        
        let pilot = container.resolve(Pilot.self)
        XCTAssertNotNil(pilot)
        XCTAssertTrue(pilot is AtAtPilot)
        XCTAssertTrue(pilot?.name() == "Joe")
        
        let type = container.resolve(Walkable.self)
        XCTAssertNotNil(type)
        XCTAssertTrue(type is AtAt)
        XCTAssertTrue(type?.numberOfLimbs() == 4)
        
        let atat = type as? AtAt
        XCTAssertNotNil(atat?.pilot)
        XCTAssertTrue(atat?.pilot is AtAtPilot)
        XCTAssertTrue(atat?.pilot.name() == "Joe")
    }
}
