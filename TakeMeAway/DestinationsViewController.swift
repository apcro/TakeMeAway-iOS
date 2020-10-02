//
//  DestinationsViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 04/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import Koloda
import Kingfisher
import SVProgressHUD
import MaterialComponents
import Firebase
import Flurry_iOS_SDK
import Toast_Swift

class DestinationsViewController: UIViewController, KolodaViewDelegate, KolodaViewDataSource {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var reloadButtonContainer: UIView!
    var reloadButton: MDCFloatingButton!
    
    @IBOutlet weak var filtersButtonContainer: UIView!
    var filtersButton: MDCFloatingButton!
    
    @IBOutlet weak var savedItemsButtonContainer: UIView!
    var savedItemsButton: MDCFloatingButton!
    
    @IBOutlet weak var outOfCardsMessageContainer: UIStackView!
    @IBAction func userDidTapLoadMoreButton(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Loading Destinations")
        UIView.animate(withDuration: 0.5, animations: {()
            self.outOfCardsMessageContainer.alpha = 0.0
            self.kolodaView.alpha = 1.0
        })
        // clear out current cards and start again
        self.destinations = []
        self.rejectedDestinations = []
        updateData()
    }
    
    var destinations: [Destination] = [] {
        didSet {
            if !self.isViewLoaded { return }
            
            // if we have just appended, just reload rather than refresh
            if oldValue.count > 0 && destinations.count > 0 {
                
                kolodaView.reloadData()
            } else {
                // moved to empty to from empty, so reset index (automatically reloads)
                kolodaView.resetCurrentCardIndex()
            }
            SVProgressHUD.dismiss()
        }
    }
    
    var currentUser: User? {
        didSet {
            updateAvatarView()
        }
    }
    
    var rejectedDestinations: [Destination] = [] {
        didSet {
            UIView.animate(withDuration: 0.5, animations: {()
                
                if self.kolodaView.currentCardIndex > 0 {
                    self.reloadButtonContainer.alpha = 1.0
                } else {
                    self.reloadButtonContainer.alpha = 0.0
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateAvatarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateAvatarView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // set font family for all my view's subviews
        setFontFamilyForView("Muli-Regular", view: view, andSubviews: true)

        // Do any additional setup after loading the view.
        kolodaView.appearanceAnimationDuration = 0.4
        kolodaView.delegate = self
        kolodaView.dataSource = self
        
        reloadButtonContainer.alpha = 0.0
        reloadButton = MDCFloatingButton(frame:reloadButtonContainer.bounds)
        reloadButton.contentMode = .scaleAspectFit
        reloadButton.addTarget(self, action: #selector(userDidTapReloadButton(sender:)), for: .touchUpInside)
        reloadButton.setImage(UIImage(named:"ic_undo_white_24dp"), for: .normal)
        reloadButton.setBackgroundColor(UIColor.TMAColors.DarkTeal, for: .normal)
        reloadButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        reloadButtonContainer.addSubview(reloadButton)
  
        filtersButtonContainer.alpha = 0.0
        filtersButton = MDCFloatingButton(frame:filtersButtonContainer.bounds)
        filtersButton.addTarget(self, action: #selector(userDidTapFiltersButton(sender:)), for: .touchUpInside)
        filtersButton.setImage(UIImage(named:"ic2_filters"), for: .normal)
        filtersButton.setBackgroundColor(UIColor.TMAColors.DarkTeal, for: .normal)
        filtersButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        filtersButtonContainer.addSubview(filtersButton)
        
        
        savedItemsButtonContainer.alpha = 0.0
        savedItemsButton = MDCFloatingButton(frame:savedItemsButtonContainer.bounds)
        savedItemsButton.addTarget(self, action: #selector(userDidTapSavedItemsButton(sender:)), for: .touchUpInside)
        savedItemsButton.setImage(UIImage(named:"ic_favorite_white_24dp"), for: .normal)
        savedItemsButton.setBackgroundColor(UIColor.TMAColors.DarkTeal, for: .normal)
        savedItemsButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        savedItemsButtonContainer.addSubview(savedItemsButton)
        
        updateData()
        
        avatarView.clipsToBounds = true
        avatarView.layer.borderWidth = 1.0
        avatarView.layer.borderColor = UIColor.TMAColors.LightTeal.cgColor
        avatarView.layer.cornerRadius = avatarView.bounds.size.width / 2.0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userDidTapAvatar))
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(tapGestureRecognizer)
        
        setAvatarImage()
        updateAvatarView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func userDidTapAvatar(sender: Any?) {
        self.accountShowPage(AccountPageBox(.profile), sender: self)
    }
    
    @objc func setAvatarImage() {
        let user = self.currentUser(sender: self)
        if let avatar = user?.avatar {
            let url = URL(string: avatar)
            avatarView.kf.setImage(with: url)
        } else {
            avatarView.image = UIImage(named: "ic2_profile")
            avatarView.isHidden = false
        }
    }
    
    @objc func updateAvatarView() {
        if (isLoggedIn(sender: self)) {
            setAvatarImage()
            avatarView.isHidden = false
            filtersButtonContainer.alpha = 1.0
            savedItemsButtonContainer.alpha = 1.0
        } else {
            avatarView.isHidden = true
            filtersButtonContainer.alpha = 0.0
            savedItemsButtonContainer.alpha = 0.0
        }
    }

    @objc func clearDestinations() {
        kolodaView.resetCurrentCardIndex()
    }
    
    //    MARK: Data updates
    func updateData() {
        SVProgressHUD.show(withStatus: "Loading destinations...")
        
        fetchDestinations(sender: self) {
            [weak self] arr, error in
            guard let `self` = self else {
                SVProgressHUD.dismiss()
                return
            }
            
            // hide spinner on error
            if error != nil {
                // this is where error 4 seems to appear
                
                if self.isLoggedIn(sender: self) {
    
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Sorry", message: "Unable to fetch more destinations. Try changing your budget. Error code 2", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Change Filters", style: .default, handler: self.userDidTapFiltersButton))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                } else {
                    
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Sorry", message: "Unable to fetch destinations. ErrorCode: 2", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Filters", style: .default, handler: self.userDidTapFiltersButton))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.destinations = arr
            }
        }
        
        updateAvatarView()
        
    }
    
    @objc func userDidTapFiltersButton(sender: Any?) {
        self.accountShowPage(AccountPageBox(.filters), sender: self)
    }
    
    @objc func userDidTapSavedItemsButton(sender: Any?) {
        self.destinationShowPage(DestinationPageBox(.savedItems), sender: self)
    }
    
    @objc func userDidTapReloadButton(sender: Any?) {
        kolodaView.revertAction()
    }
    
    // MARK: - Koloda Delegates
    
    // datasource
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if (index > destinations.count) {
            print("too many index")
        }
        let card = DestinationCardView()
        
        // TODO: configure card for data
        // sometimes index is too large?
        let destination = destinations[index]
        if let cityImage = destination.cityImage {
            card.imageView.kf.setImage(with: URL(string: cityImage))
        }
        card.cityLabel.text = destination.cityName
        card.countryLabel.text = destination.countryName.uppercased()
        card.descriptionLabel.text = destination.cityDescription
        card.priceLabel.text = " from " + wrapPrice(destination.flightCost) + "p/p"
        

        card.hotelPrice.isHidden = true
        card.hotelIconView.isHidden = true
        
        let number = Int(arc4random_uniform(8)) - 4
        let rotation = (CGFloat(Int(number)) * CGFloat.pi) / 180
        
        card.transform = CGAffineTransform(rotationAngle: rotation)
        
        if destination.temperature != "-999" {
            card.weatherdescription.text = (destination.temperature ?? "") + "° " + (destination.weatherDescription ?? "")
        } else {
            card.weatherdescription.text = ""
        }
        
        let saveRec = UITapGestureRecognizer(target: self, action: #selector(userDidTapSaveIcon))
        card.saveIcon.addGestureRecognizer(saveRec)
        
        return card
    }
    
    @objc func userDidTapSaveIcon(sender: Any?) {
        let destination = destinations[kolodaView.currentCardIndex]
        saveHotelAndDestination(sender: self, hotelId: 0, cityId: destination.cityId, flightPrice: destination.flightCost, hotelPrice: 0, completion: {(error) in
            if error != nil {
                // TODO: decide if this is worth notifying user about
            }
        })
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return destinations.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .moderate
    }
    
    // delegate
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let destination = destinations[index]
        let user = self.currentUser(sender: self)
        let people = user?.people ?? 1
        let budget = user?.budget ?? 2000
        
        if direction == .right {
            let articleParams = [
                "action": "Swiped RIGHT on city",
                "destinationCityAirport": destination.iata,
                "destinationCityName": destination.cityName,
                "destinationCityId": String(destination.cityId),
                "prefs.people": String(people),
                "prefs.budget": String(budget),
                "prefs.weekend": user?.travelDates
            ];
            Flurry.logEvent("DestinationSwipe", withParameters: articleParams as [AnyHashable : Any]);
            
            showHotelsForDestination(sender: self, destination: destination)
            
        } else if direction == .left {
            
            let articleParams = [
                "action": "Swiped LEFT on city",
                "destinationCityAirport": destination.iata,
                "destinationCityName": destination.cityName,
                "destinationCityId": String(destination.cityId),
                "prefs.people": String(people),
                "prefs.budget": String(budget),
                "prefs.weekend": user?.travelDates
                ];
            Flurry.logEvent("DestinationSwipe", withParameters: articleParams as [AnyHashable : Any]);
            rejectedDestinations.append(destination)
        
            if self.kolodaView.currentCardIndex > 0 {
                self.reloadButtonContainer.alpha = 1.0
            } else {
                self.reloadButtonContainer.alpha = 0.0
            }
        
            topUp(amount: 1)
        }
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        // TODO: show some sort of message
        UIView.animate(withDuration: 0.5, animations: {()
            self.outOfCardsMessageContainer.alpha = 1.0
            self.kolodaView.alpha = 0.0
        })
        topUp(amount: 3)
    }
    
    func topUp(amount: Int) {
        topUpAvailableDestinations(sender: self, amount: amount, completion: { (newDestinations, error) in
            //            if let error = error {
            if error != nil {
                if self.isLoggedIn(sender: self) {
                    SVProgressHUD.dismiss()
                    
                    self.view.makeToast("Unable to find more destinations. Try changing your budget.")
                    
                    self.outOfCardsMessageContainer.alpha = 0.0
                    self.kolodaView.alpha = 1.0
                } else {
                    self.view.makeToast("Unable to find more destinations.")

                }
                
            } else {
                print("\(newDestinations[0].cityName)")
                self.destinations.append(contentsOf: newDestinations)
                self.outOfCardsMessageContainer.alpha = 0.0
                self.kolodaView.alpha = 1.0
            }
        })
    }

}
