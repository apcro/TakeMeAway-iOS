//
//  HotelAvailability.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal

final class HotelAvailability: NSObject, Unmarshaling {
    let hotelId: Int
    let name: String
    let price: Float
    let currencyCode: String
    let rooms: [Room]
    
    init(hotelId: Int, name: String, price: Float, currencyCode: String, rooms: [Room]) {
        self.hotelId = hotelId
        self.name = name
        self.price = price
        self.currencyCode = currencyCode
        self.rooms = rooms
    }
    
    init(object: MarshaledObject) throws {
        hotelId = try Int(object.value(for: "hotel_id") as String)!
        name = try object.value(for: "name")
        price = try Float(object.value(for: "price") as String)!
        currencyCode = try object.value(for: "hotel_currency_code")
        rooms = try object.value(for: "rooms")
    }
    
}
