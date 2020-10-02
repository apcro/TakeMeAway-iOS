//
//  Destination.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 05/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal

final class Destination: NSObject, Unmarshaling {
    let cityId: Int
    let cityName: String
    let cityImage: String?
    let countryName: String
    let iata: String?
    let lat: Float
    let lon: Float
    let googlePlaceId: String?
    let cityDescription: String?
    let flightCost: Int
    let currencyCode: String?
    var flightRefUri: String?
    let flightCurrency: String?
    let temperature: String?
    let weatherDescription: String?
    let weatherIcon: String?
    var hotels: [Hotel]?
    
    init(cityId: Int, cityName: String, countryName: String, iata: String?, lat: Float, lon: Float, googlePlaceId: String?,
         cityDescription: String?, cityImage:String?, flightCost: Int, currencyCode: String?, flightRefUri: String?, flightCurrency: String?, temperature: String?, weatherDescription: String?, weatherIcon: String?, hotels: [Hotel]) {
        self.cityId = cityId
        self.cityName = cityName
        self.cityImage = cityImage
        self.countryName = countryName
        self.iata = iata
        self.lat = lat
        self.lon = lon
        self.googlePlaceId = googlePlaceId
        self.cityDescription = cityDescription
        self.flightCost = flightCost
        self.currencyCode = currencyCode
        self.flightRefUri = flightRefUri
        self.flightCurrency = flightCurrency
        self.temperature = temperature
        self.weatherDescription = weatherDescription
        self.weatherIcon = weatherIcon
        self.hotels = hotels
    }
    
    init(object: MarshaledObject) throws {
        cityId = try Int(object.value(for: "cityId") as String)!
        lon = try Float(object.value(for: "lon") as String)!
        lat = try Float(object.value(for: "lat") as String)!
        
        cityName = try object.value(for: "cityName")
        cityDescription = try object.value(for: "cityDescription")
        cityImage = try "{cdnurl}" + object.value(for: "cityImage") // TODO: move this url base to PList
        countryName = try object.value(for: "countryName")
        iata = try object.value(for: "iata")
        googlePlaceId = try object.value(for: "googlePlaceId")
        flightCost = try object.value(for: "flightcost") ?? 0
        currencyCode = try object.value(for: "currencycode")
        flightRefUri = try object.value(for: "flightref")
        flightCurrency = try object.value(for: "flightcurrency")
        temperature = try object.value(for: "temperature")
        weatherDescription = try object.value(for: "weather_description")
        weatherIcon = try object.value(for: "weather_icon")
        
        hotels = try object.value(for: "hotels")
    }
    
    init(saveditem: SavedItem) throws {
        cityId = saveditem.cityId
        lon = saveditem.airportLon!
        lat = saveditem.airportLat!
        
        cityName = saveditem.cityName
        cityDescription = ""
        cityImage = saveditem.cityImage // TODO: move this url base to PList
        countryName = saveditem.country
        iata = ""
        googlePlaceId = ""
        flightCost = 0
        currencyCode = ""
        flightRefUri = ""
        flightCurrency = ""
        temperature = ""
        weatherDescription = ""
        weatherIcon = ""
        
        hotels = []
    }

}
