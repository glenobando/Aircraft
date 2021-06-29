//
//  FlightDetail.swift
//  Aircraft
//
//  Created by Glen Obando on 28/6/21.
//

import Foundation

struct FlightDetail {
    var airportIataCode: String?
    var terminal: String?
    var gate: String?
    var scheduledTime: String?
    var actualTime: String?
    var estimatedTime: String?
    var delay: String?
    var iataNumber: String?
    var status: String?
    
    func delaystatus() -> String {
        if delay != ""{
            return "delayed"
        } else {
            return "on-time"
        }
    }
}
