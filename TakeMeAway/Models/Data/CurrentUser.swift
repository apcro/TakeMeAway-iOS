//
//  CurrentUser.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import UIKit

final class CurrentUser {
    
    let id: Int
    let firstName: String
    let lastName: String
    var avatar: String?
    
    var placeId: String?
    var placeName: String?
    
    var postCode: String?
    var lat: Float?
    var lon: Float?
    
    var avatarImage: UIImage?
    
    init(id: Int, firstName: String, lastName: String, avatar: String?, placeId: String?, placeName: String?, postCode: String?, lat: Float?, lon: Float?, avatarImage: UIImage?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.placeId = placeId
        self.placeName = placeName
        self.postCode = postCode
        self.lat = lat
        self.lon = lon
        self.avatarImage = avatarImage
    }
    
    init(id: Int, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
    
    init(user: User) {
        self.id = user.id
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.avatar = user.avatar
        self.placeId = nil
        self.placeName = nil
        self.postCode = nil
        self.lat = user.lat
        self.lon = user.lon
    }
}
