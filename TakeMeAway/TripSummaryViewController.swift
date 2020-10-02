//
//  TripSummaryViewController.swift
//  TakeMeAway
//
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim

import UIKit
import SVProgressHUD
import Flurry_iOS_SDK

class TripSummaryViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityDescription: UILabel!
    @IBOutlet weak var tripCostLabel: UILabel!
    @IBOutlet weak var peopleLabel: UILabel!
    
    @IBOutlet weak var flightBookingButton: UIView!
    @IBOutlet weak var hotelBookingButton: UIView!
    @IBOutlet weak var emailLinksButton: UIView!
    
    @IBOutlet weak var cityImageView: UIImageView!
    
    @IBOutlet weak var flightDetailsLabel: UILabel!
    @IBOutlet weak var hotelNameLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIImageView!
    
    // local data models
    var trip: Trip! {
        didSet {
            if isViewLoaded {
                // enable/disable buttons accordingly
            }
        }
    }

    var user: User? {
        didSet {
            if isViewLoaded {
                renderData()
            }
        }
    }
    
    var flightBookingLink: String? {
        didSet {
        }
    }
    
    var hotelBookingLink: String? {
        didSet {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userDidTapEmailMeDetailsButton(sender: Any?) {
        if let trip = trip {
            SVProgressHUD.show()
            self.emailTripDetails(sender: self, trip: trip, completion: { (success, error) in
                if success {
                    SVProgressHUD.showSuccess(withStatus: "Email sent")
                } else {
                    SVProgressHUD.showError(withStatus: "Unable to send email")
                }
            })
            user = currentUser(sender: self)
            let reachabilityManager = ReachabilityManager()
            let api = TakeMeAwayService(reachabilityManager: reachabilityManager)
            let dataManager = DataManager(api: api)
            let loginManager = LoginManager(api: api, dataManager: dataManager, shouldClearKeychain: false)
            let articleParams = [
                "token": loginManager.authToken,
                "bookingType": "Email Details",
                "originAirport": user?.homeAirport,
                "destinationAirport": trip.destination.iata,
                "destinationCity": trip.destination.cityName,
                "destinationCityId": String(trip.destination.cityId),
                "hotelId": String(trip.hotel.id),
                "value": String(trip.destination.flightCost + Int(trip.hotel.price)),
                "currency": trip.hotel.currencyCode,
                "prefs.people": String(user?.people ?? 1),
                "prefs.budget": String(user?.budget ?? 2000),
                "prefs.weekend": user?.travelDates
            ];
            Flurry.logEvent("BeginCheckout", withParameters: articleParams);

        }
    }
    
    // MARK: Data Rendering
    func renderData() {
            
        // fill in ui with trip details
        if let cityImage = trip.destination.cityImage {
            cityImageView.kf.setImage(with: URL(string:cityImage))
        }
        
        cityNameLabel.text = trip.destination.cityName
        cityNameLabel?.font = UIFont(name: "Catamaran-ExtraBold", size: 32.0)
        
        hotelNameLabel.text = trip.hotel.name
        
        var flightDetailsText = "Return flights for \(trip.numPeople)"
        if (trip.numPeople == 1) {
            flightDetailsText += " person"
        } else {
            flightDetailsText += " people"
        }
        
        flightDetailsLabel.text = flightDetailsText
   
        let flightCost = trip.destination.flightCost
        let hotelCost = Int(trip.room!.price)
        var costDetailsText = ""
        
        if (flightCost >= 0 && hotelCost > 0) {
            let totalPrice = (flightCost * trip.numPeople) + hotelCost
            tripCostLabel.text = wrapPrice(totalPrice)
            costDetailsText = "C"
        } else if flightCost >= 0 {
            costDetailsText = "Flight c"
            let totalPrice = (flightCost * trip.numPeople)
            tripCostLabel.text = wrapPrice(totalPrice)
        }
        tripCostLabel?.font = UIFont(name: "Catamaran-ExtraBold", size: 32.0)
        
        costDetailsText += "ost for \(trip.numPeople)"
        if (trip.numPeople == 1) {
            costDetailsText += " person"
        } else {
            costDetailsText += " people"
        }
        peopleLabel.text = costDetailsText
        
        cityDescription.text = trip.destination.cityDescription
        

        
        let flightTap = UITapGestureRecognizer(target: self, action: #selector(userTappedFlightButton))
        flightBookingButton.addGestureRecognizer(flightTap)
        
        let hotelTap = UITapGestureRecognizer(target: self, action: #selector(userTappedHotelButton))
        hotelBookingButton.addGestureRecognizer(hotelTap)
        
        let emailTap = UITapGestureRecognizer(target: self, action: #selector(userDidTapEmailMeDetailsButton))
        emailLinksButton.addGestureRecognizer(emailTap)
        
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(onClickedCloseButton))
        closeButton.addGestureRecognizer(closeTap)

    }
 
    // GestureRecognizer
    @objc func userTappedFlightButton(gesture: UITapGestureRecognizer) -> Void {
        //Write your code here
        if let trip = trip {
            trip.hotel.bookingLink = hotelBookingLink
            showTripBooking(sender: self, trip: trip, tab: 0)
        }
    }
 
    @objc func userTappedHotelButton(gesture: UITapGestureRecognizer) -> Void {
        //Write your code here
        if let trip = trip {
            trip.destination.flightRefUri = flightBookingLink
            trip.hotel.bookingLink = hotelBookingLink
            showTripBooking(sender: self, trip: trip, tab: 1)
        }
    }
    
    func introTextForDestination(destination: Destination) -> String {
        return "Ready for your trip to \(destination.cityName)?"
    }

    @objc func onClickedCloseButton(gesture: UITapGestureRecognizer) -> Void {
        print("tapped close")
        goHome(sender: self)
    }
}
