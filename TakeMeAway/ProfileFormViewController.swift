//
//  ProfileFormViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 27/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import Eureka
import SVProgressHUD
import CoreLocation

struct AirportChoice {
    let code: String
    let name: String
    let lat: Float
    let lon: Float
}

class ProfileFormViewController: FormViewController {
    
    var user: User? {
        didSet {
            if isViewLoaded { renderData() }
            if oldValue == nil {
                // fetch airport details
                if let iata = user?.homeAirport {
                    getAirportDetails(iata: iata, completion: {(airport, error) in
                        if let airport = airport {
                            self.selectedAirport = AirportChoice(code: airport.iata, name: "\(airport.city), \(airport.name)", lat: airport.lat, lon: airport.lon)
                            if self.isViewLoaded { self.renderData() }
                        } else {
                            print("Error loading airport details: \(error.debugDescription)")
                        }
                    })
                    
                }
            }
        }
    }
    
    var selectedAirport: AirportChoice? {
        didSet {
            if let user = user, let airport = selectedAirport {
                user.homeAirport = airport.code
            }
        }
    }

    var airports = [
        AirportChoice(code: "AUTO", name: "Auto-select your nearest", lat: 0.0, lon: 0.0),
        AirportChoice(code: "LON", name: "London (All Airports)", lat: 0.0, lon: 0.0),
        AirportChoice(code: "AMS", name: "Amsterdam, Schipol", lat: 0.0, lon: 0.0),
        AirportChoice(code: "MAN", name: "Manchester", lat: 0.0, lon: 0.0),
        AirportChoice(code: "BHX", name: "Birmingham", lat: 0.0, lon: 0.0),
        AirportChoice(code: "OTP", name: "Bucharest, Henri Coanda", lat: 0.0, lon: 0.0),
        AirportChoice(code: "CWL", name: "Cardiff", lat: 0.0, lon: 0.0),
        AirportChoice(code: "ABZ", name: "Aberdeen", lat: 0.0, lon: 0.0),
        AirportChoice(code: "GLA", name: "Glasgow", lat: 0.0, lon: 0.0)
    ]
    
    var profileImageView: UIImageView!
    let picker = UIImagePickerController()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let airportsSection = self.renderAirportsSection()
        
        let resetTutorialSection = Section()
        <<< ButtonRow("resetTutorial") {
                $0.title = "Reset Tutorial"
            }.onCellSelection({ (cell, row) in
                let userDefaults = UserDefaults.standard
                userDefaults.set(false, forKey: "hasRunBefore")
                userDefaults.synchronize()
                self.helpShowPage(HelpPageBox(.onboarding), sender: self)
            })
        
        let userDetailsSection = Section() { section in
            var header = HeaderFooterView<ProfileFormHeaderView>(.class)
            header.onSetupView = { view, _ in
                self.profileImageView = view.imageView
                if let imgString = self.user?.avatar {
                    self.profileImageView.kf.setImage(with: URL(string: imgString))
                }
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.chooseAvatar))
                self.profileImageView.addGestureRecognizer(tap)
                self.profileImageView.isUserInteractionEnabled = true
            }
            header.height = {128}
            section.header = header
            }
            <<< TextRow("username") {
                $0.title = "Username"
            }.onCellHighlightChanged { cell, row in
                if !cell.isHighlighted {
                    self.saveChanges(persist: false)
                }
            }
            <<< EmailRow("email") {
                $0.title = "Email"
            }.onCellHighlightChanged { cell, row in
                if !cell.isHighlighted {
                    self.saveChanges(persist: false)
                }
            }
            <<< NameRow("first_name") {
                $0.title = "First Name"
            }.onCellHighlightChanged { cell, row in
                if !cell.isHighlighted {
                    self.saveChanges(persist: false)
                }
            }
            <<< NameRow("last_name") {
                $0.title = "Last Name"
            }.onCellHighlightChanged { cell, row in
                if !cell.isHighlighted {
                    self.saveChanges(persist: false)
                }
            }
            <<< LabelRow("home_airport_name") {
                $0.title = "Home Airport"
            }.onCellHighlightChanged { cell, row in
                if !cell.isHighlighted {
                    self.saveChanges(persist: false)
                }
            }
        
        form +++ userDetailsSection
            +++ airportsSection
            +++ resetTutorialSection
        
        form.delegate = self
        
        renderData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Profile"
        self.getNearestAirports()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
        
        saveChanges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderData() {
        // fill in form data from user model
        form.setValues(["username": user?.username, "email": user?.email, "first_name": user?.firstName, "last_name": user?.lastName, "home_airport_name": user?.homeAirport])
        
        form.sectionBy(tag: "airportsSection")?.removeAll()
        form.sectionBy(tag: "airportsSection")?.append(contentsOf: renderAirportsSection())
        
        tableView.reloadData()
    }
    
    func renderAirportsSection()-> SelectableSection<ListCheckRow<String>> {
        let airportsSection = SelectableSection<ListCheckRow<String>>("Tap To Set Home Airport", selectionType: .singleSelection(enableDeselection: false))
        
        airportsSection.tag = "airportsSection"
        
        for airport in self.airports {
            airportsSection <<< ListCheckRow<String>{ listRow in
                listRow.tag = "airport:\(airport.code)"
                listRow.title = airport.name
                listRow.selectableValue = airport.code
                listRow.value = nil
                }.onChange { row in
                    if row.baseValue != nil {
                        let value = row.selectableValue
                        if value == "AUTO" {
                            // select airport automatically
                            self.getNearestAirportToUser()
                        } else {
                            self.user?.homeAirport = row.title!
                            self.selectedAirport = AirportChoice(code: row.selectableValue!, name: row.title!, lat: 0.0, lon: 0.0)
                            self.renderData()
                        }
                    }
            }
        }
        return airportsSection
    }
    
    
    // MARK: Actions
    
    @objc func chooseAvatar() {
        // launch photo chooser
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    @objc func getNearestAirportToUser() {
        
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                locationManager.requestWhenInUseAuthorization()
                break
            
            case .restricted, .denied:
                // unselect auto
                if let autoRow: ListCheckRow<String> = self.form.rowBy(tag: "airport:AUTO") {
                    autoRow.baseValue = nil
                    autoRow.reload()
                }
                
                // ask to enable permissions
                let alert = UIAlertController(title: "Need Authorization", message: "This app cannot detect airport automatically without location services", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                break
            
            case .authorizedWhenInUse, .authorizedAlways:
                // get location and fire api call
                SVProgressHUD.show(withStatus: "Acquiring location...")
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
                locationManager.startUpdatingLocation()
        }
    }
    
    func getNearestAirports() {
        getAirports(lat: (user?.lat)!, lon: (user?.lon)!, sender: self, completion: {(nearestAirports, error) in

            self.airports.removeAll()
            self.airports.append(AirportChoice(code: "AUTO", name: "Auto-select your nearest", lat: 0.0, lon: 0.0))
            for airport in nearestAirports {
                self.airports.append(AirportChoice(code: airport.iata, name: airport.name, lat: airport.lat, lon: airport.lon))
            }
            self.renderData()
        })
        
    }

    func saveChanges(persist: Bool = true) {
        let data = form.values()
        
        user?.username = data["username"] as! String
        user?.email = data["email"] as! String
        user?.firstName = data["first_name"] as! String
        user?.lastName = data["last_name"] as! String
        
        if persist {
            updateUserProfile(user: user!, sender: self, completion: {(error) in
                if let error = error {
                    // TODO: handle error
                    print("Error saving profile: \(error)")
                }
            })
        }
    }
}

extension ProfileFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.image = pickedImage
            
            // encode and upload photo
            updateAvatar(avatar: pickedImage, sender: self, completion: {(error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Error uploading photo!")
                }
            })
        }
        
        dismiss(animated:true, completion: nil)
    }
}

extension ProfileFormViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // extract coordinates
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        // ask api for nearest airport
        getNearestAirport(lat: Float(locValue.latitude), lon: Float(locValue.longitude), completion: {(airport, error) in
            if let airport = airport {
                self.user?.homeAirport = airport.iata
                self.selectedAirport = AirportChoice(code: airport.iata, name: "\(airport.city), \(airport.name)", lat: 0.0, lon: 0.0)
                self.renderData()
            }
            SVProgressHUD.dismiss()
        })
        
        // stop location updates
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            getNearestAirportToUser()
        }
    }
}
