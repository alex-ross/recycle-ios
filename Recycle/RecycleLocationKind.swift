//
//  RecycleLocationKind.swift
//  Recycle
//
//  Created by Alexander Ross on 2019-08-05.
//  Copyright © 2019 Standout AB. All rights reserved.
//

import Foundation

enum RecycleLocationKind: String, Decodable {
    case recycleStation = "recycle_station"
    case recycleCenter = "recycle_center"
    case other = "other"

    init(rawValue: String) {
        switch rawValue {
        case "recycle_station": self = .recycleStation
        case "recycle_center": self = .recycleCenter
        default: self = .other
        }
    }

    var localized: String {
        switch self {
        case .recycleStation:
            return "Återvinningstation"
        case .recycleCenter:
            return "Återvinningcentral"
        default:
            return "Okänd typ"
        }
    }
}
