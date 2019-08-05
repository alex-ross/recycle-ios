//
//  CLLocationCoordinate2D+Decodable.swift
//  Recycle
//
//  Created by Alexander Ross on 2019-08-05.
//  Copyright © 2019 Standout AB. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Decodable {

    enum CodingKeys: String, CodingKey {
        case longitude
        case latitude
    }

    public init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)

        self.init()

        latitude = try values.decode(CLLocationDegrees.self, forKey: .latitude)
        longitude = try values.decode(CLLocationDegrees.self, forKey: .longitude)
    }

}
