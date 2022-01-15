//
//  guitar_dashboardTests.swift
//  guitar-dashboardTests
//
//  Created by Guglielmo Frigerio on 15/01/22.
//

import XCTest
@testable import guitar_dashboard

class guitar_dashboardTests: XCTestCase {
    
    class MidiEndpointListener : MidiEndpointListenerProtocol {
        var availCount = 0
        var unavailCount = 0
        func endpointAvailable(name: String, index: Int) {
            print("endpoint \(name) available at index \(index)")
            availCount += 1
        }
        
        func endpointUnavailable(name: String) {
            print("endpont \(name) no more available")
            unavailCount += 1
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSubsAndUnsubs() throws {
        let midiEndpointListener = MidiEndpointListener()
        let endpointCollection = MidiEndpointCollection()
        
        endpointCollection.subscribe(name: "myEndpoint", listener: midiEndpointListener)
        
        let endpoints = ["myEndpoint": 0, "anotherEndpoint": 1]
        
        endpointCollection.compareCollection(endpoints: endpoints)
        
        XCTAssert(midiEndpointListener.availCount == 1)
        XCTAssert(midiEndpointListener.unavailCount == 0)

        let endpoints2 = ["fristEndpoint": 0, "anotherEndpoint": 1]
        endpointCollection.compareCollection(endpoints: endpoints2)
        XCTAssert(midiEndpointListener.availCount == 1)
        XCTAssert(midiEndpointListener.unavailCount == 1)

    }

    func testBasicSubscription() throws {
        
        let midiEndpointListener = MidiEndpointListener()
        let endpointCollection = MidiEndpointCollection()
        
        endpointCollection.subscribe(name: "myEndpoint", listener: midiEndpointListener)
        
        let endpoints = ["myEndpoint": 0, "anotherEndpoint": 1]
        
        endpointCollection.compareCollection(endpoints: endpoints)
        
        XCTAssert(midiEndpointListener.availCount == 1)
        XCTAssert(midiEndpointListener.unavailCount == 0)

        endpointCollection.compareCollection(endpoints: endpoints)
        XCTAssert(midiEndpointListener.availCount == 1)
        XCTAssert(midiEndpointListener.unavailCount == 0)

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
