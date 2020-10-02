//
//  TakeMeAwayAPI.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 06/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Moya
import Moya_Marshal

enum TakeMeAwayAPI {
    // POST
    case login(username: String, password: String, type: String)
    case logout()
    case register(email: String, password: String, name: String, locale: String)
    case updateProfile(username: String, firstName: String, lastName: String, email: String, homeAirport: String, lat: Float, lon: Float)
    case updateSettings(budget: Int, people: Int, split: Int, dates: String, filters: String, currency: String, locale: String, leaveday: String, returnday: String, leaveDate: Double, returnDate: Double)
    case saveItem(cityId: Int, hotelId: Int, flightPrice: Int, hotelPrice: Int)
    case deleteSavedItem(cityId: Int, hotelId: Int)
    case submitFeedback(feedback: String)
    case updateDeviceToken(deviceToken: String, deviceType: String)
    case emailTripDetails(cityId: String, hotelId: String)
    // POST Multipart
    case updateAvatar(avatar: UIImage)
    // GET
    case destinations(count: Int)
    case personalisedDestinations(count: Int)
    case hotels(count: Int, cityId: Int, extraHotelId: Int, flightCost: String)
    case cityDetails(cityId: Int)
    case hotelDetails(hotelId: Int)
    case roomDetails(hotelId: Int)
    case userDetails()
    case airports(lat: Float, lon: Float)
    case nearestAirport(lat: Float, lon: Float)
    case airportDetails(iata: String)
    case savedItems()
    case savedItemDetails(cityId: Int, hotelId: Int)
    case checkHotelAvailability(hotelIds: String)
}

extension TakeMeAwayAPI: TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        return URL(string: "{api url here}")!
    }
    
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .logout:
            return "/logout"
        case .register:
            return "/register"
        case .updateProfile:
            return "/updateProfile"
        case .updateSettings:
            return "/updateSettings"
        case .saveItem:
            return "/saveItem"
        case .deleteSavedItem:
            return "deleteSavedItem"
        case .submitFeedback:
            return "/sendFeedback"
        case .updateDeviceToken:
            return "/updateDeviceToken"
        case .emailTripDetails:
            return "/emailTrip"
            
        case .updateAvatar:
            return "/updateAvatar"
            
        case .destinations:
            return "/findDestination"
        case .personalisedDestinations:
            return "/findDestination"
        case .hotels:
            return "/findHotel"
        case .cityDetails:
            return "/getCityDetails"
        case .hotelDetails:
            return "/getHotelDetails"
        case .roomDetails:
            return "/getRoomDetails"
        case .userDetails:
            return "/userLoad"
        case .airports:
            return "/getAirports"
        case .nearestAirport:
            return "/getNearestAirport"
        case .airportDetails:
            return "/getAirportDetails"
        case .savedItems:
            return "/loadSavedItems"
        case .savedItemDetails:
            return "/loadSavedItem"
        case .checkHotelAvailability:
            return "/checkHotelAvailability"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .logout, .register, .updateProfile, .updateSettings, .saveItem, .deleteSavedItem, .submitFeedback, .updateDeviceToken, .updateAvatar, .emailTripDetails:
            return .post
        case .destinations, .personalisedDestinations, .hotels, .cityDetails, .hotelDetails, .roomDetails, .userDetails, .airports, .nearestAirport, .airportDetails, .savedItems, .savedItemDetails, .checkHotelAvailability:
            return .get
        }
    }
    
    var task: Task {
        var p = [String: Any]()
        switch self {
        
        case .login(let username, let password, let type):
            p["username"] = username
            p["password"] = password
            p["type"] = type
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
        
        case .register(let email, let password, let name, let locale):
            p["email"] = email
            p["password"] = password
            p["name"] = name
            p["locale"] = locale
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
        
        case .updateProfile(let username, let firstName, let lastName, let email, let homeAirport, let lat, let lon):
            p["username"] = username
            p["firstname"] = firstName
            p["lastname"] = lastName
            p["email"] = email
            p["home_airport"] = homeAirport
            p["latitude"] = lat
            p["longitude"] = lon
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .updateSettings(let budget, let people, let split, let dates, let filters, let currency, let locale, let leaveday, let returnday, let leavedate, let returndate):
            p["budget"] = budget
            p["people"] = people
            p["split"] = split
            p["dates"] = dates
            p["filters"] = filters
            p["currency"] = currency
            p["locale"] = locale
            p["leaveday"] = leaveday
            p["returnday"] = returnday
            p["leaveDate"] = Int(leavedate)
            p["returnDate"] = Int(returndate)
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .saveItem(let cityId, let hotelId, let flightPrice, let hotelPrice):
            p["cityId"] = cityId
            p["hotelId"] = hotelId
            p["flightprice"] = flightPrice
            p["hotelprice"] = hotelPrice
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .deleteSavedItem(let cityId, let hotelId):
            p["cityId"] = cityId
            p["hotelId"] = hotelId
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)

        case .submitFeedback(let feedback):
            p["feedback"] = feedback
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .updateDeviceToken(let deviceToken, let deviceType):
            p["deviceToken"] = deviceToken
            p["deviceType"] = deviceType
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .emailTripDetails(let cityId, let hotelId):
            p["cityId"] = cityId
            p["hotelId"] = hotelId
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .updateAvatar(let avatar):
            guard let jpegRep = avatar.jpegData(compressionQuality: 1.0) else { return .uploadMultipart([]) }
            let jpegData = MultipartFormData(provider: .data(jpegRep), name: "avatar", fileName: "avatar.jpeg", mimeType: "image/jpeg")
            return .uploadMultipart([jpegData])
            
        case .destinations(let count), .personalisedDestinations(let count):
            p["data"] = count
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .hotels(let count, let cityId, let extraHotelId, let flightCost):
            p["city_id"] = cityId
            p["count"] = count
            p["extraHotelId"] = extraHotelId
            p["flightCost"] = flightCost
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .cityDetails(let cityId):
            p["cityid"] = cityId
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .hotelDetails(let hotelId):
            p["hotelid"] = hotelId
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .roomDetails(let hotelId):
            p["hotelid"] = hotelId
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .userDetails():
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .airports(let lat, let lon):
            p["lat"] = lat
            p["lon"] = lon
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .nearestAirport(let lat, let lon):
            p["lat"] = lat
            p["lon"] = lon
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .airportDetails(let iata):
            p["iata"] = iata
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .savedItems():
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .savedItemDetails(let cityId, let hotelId):
            p["cityId"] = cityId
            p["hotelId"] = hotelId
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
            
        case .checkHotelAvailability(let hotelIds):
            p["hotel_ids"] = hotelIds
            return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
        
        default:
            return .requestPlain
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .login, .register, .destinations, .hotels:
            return .none
        default:
            return .bearer
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    

}
