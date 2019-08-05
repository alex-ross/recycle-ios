//
//  RecycleLocationTests.swift
//  RecycleTests
//
//  Created by Alexander Ross on 2019-08-05.
//  Copyright © 2019 Standout AB. All rights reserved.
//

import XCTest
@testable import Recycle


class RecycleLocationTests: XCTestCase {
    lazy var exampleResponseBodyData: Data = {
        let bundle = Bundle.allBundles.filter { $0.bundlePath.hasSuffix(".xctest") }.first!
        let path = bundle.path(forResource: "RecycleLocationsExampleResponseBody", ofType: "json")!
        let string = try! String(contentsOfFile: path)

        return string.data(using: .utf8)!
    }()

    func testParse() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let recycleLocationsResponse = try! decoder.decode(RecycleLocationsResponse.self, from: exampleResponseBodyData)
        let recycleLocation = recycleLocationsResponse.recycleLocations.first!

        XCTAssertEqual(6782, recycleLocation.id)
        XCTAssertEqual(["glass", "cardboard", "metal", "plastic", "magazines"], recycleLocation.materials)
        XCTAssertEqual(14.46306, recycleLocation.coordinates.longitude)
        XCTAssertEqual(56.785829999999997, recycleLocation.coordinates.latitude)
        XCTAssertEqual("35423", recycleLocation.address.zipCode)
        XCTAssertEqual("Vislanda", recycleLocation.address.city)
        XCTAssertEqual(recycleLocation.openingHours, [
            OpeningHour(openAt: "06:30" as String?, closeAt: "16:00" as String?, isUnknown: false),
            OpeningHour(openAt: nil, closeAt: nil, isUnknown: true),
            OpeningHour(openAt: nil, closeAt: nil, isUnknown: true),
            OpeningHour(openAt: nil, closeAt: nil, isUnknown: true),
            OpeningHour(openAt: nil, closeAt: nil, isUnknown: true),
            OpeningHour(openAt: nil, closeAt: nil, isUnknown: true),
            OpeningHour(openAt: nil, closeAt: nil, isUnknown: true)
        ])
        XCTAssertEqual(RecycleLocationKind.recycleStation, recycleLocation.kind)
        XCTAssertEqual("Husebyvägen", recycleLocation.name)
        XCTAssertEqual("Husebyvägen 1", recycleLocation.address.street)

    }
}
