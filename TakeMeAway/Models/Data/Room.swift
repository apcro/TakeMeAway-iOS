//
//  Room.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal

final class Room: NSObject, Unmarshaling {
    let roomId: Int
    let roomName: String
    let hotelId: Int? // unused?
    let roomTypeId: Int
    let depositRequired: Bool
    let numAdults: Int
    let numRoomsAtThisPrice: Int
    let price: Float
    let refundable: Bool
    let refundableUntil: String?
    let blockId: String
    
    init(roomId: Int, roomName: String, hotelId: Int, roomTypeId: Int, depositRequired: Bool, numAdults: Int, numRoomsAtThisPrice: Int, price: Float, refundable: Bool, blockId: String, refundableUntil: String?) {
        self.roomId = roomId
        self.roomName = roomName
        self.hotelId = hotelId
        self.roomTypeId = roomTypeId
        self.depositRequired = depositRequired
        self.numAdults = numAdults
        self.numRoomsAtThisPrice = numRoomsAtThisPrice
        self.price = price
        self.refundable = refundable
        self.blockId = blockId
        self.refundableUntil = refundableUntil
    }
    
    init(object: MarshaledObject) throws {
        roomId = try object.value(for: "room_id")
        roomName = try object.value(for: "room_name")
        hotelId = try object.value(for: "city")
        roomTypeId = try object.value(for: "room_type_id")
        depositRequired = try object.value(for: "deposit_required")
        numAdults = try object.value(for: "adults")
        numRoomsAtThisPrice = try object.value(for: "num_rooms_available_at_this_price")
        price = try Float(object.value(for: "price") as String)!
        refundable = try object.value(for: "refundable")
        refundableUntil = try object.value(for: "refundable_until")
        blockId = try object.value(for: "block_id")
    }
    
}
