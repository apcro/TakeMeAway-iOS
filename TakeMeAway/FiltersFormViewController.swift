//
//  FiltersFormViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 27/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import Eureka

class FiltersFormViewController: FormViewController {
    
    @IBAction func updateDates() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateDatesDisplay"), object: nil)
    }
    
    let MAX_BUDGET = 2000
    let MIN_BUDGET = 300
    let MIN_PEOPLE = 1
    let MAX_PEOPLE = 8
    
    var user: User? {
        didSet {
            if isViewLoaded {
                renderData()
            }
        }
    }
    var formLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = currentUser(sender: self)
        
        let today = Date()
        
        var leavingDate = self.user?.leaveDate
        if leavingDate == 0 {
            // set to today
            leavingDate = today.timeIntervalSince1970
        }

        var returningDate = self.user?.returnDate
        if returningDate == 0 {
            // set to today
            returningDate = today.timeIntervalSince1970
        }
        
        // setup form
        
        SwitchRow.defaultCellSetup = { cell, row in
            cell.switchControl?.onTintColor = UIColor.TMAColors.DarkTeal
            cell.textLabel?.textColor = UIColor.TMAColors.DarkTeal
        }
        
        form +++ Section()  // TODO: supply custom zero-height view for this
            <<< SliderRow("total_budget") {
                $0.title = "Total Budget"
                $0.steps = UInt(MAX_BUDGET - MIN_BUDGET) * 2
                $0.value = 500
                $0.displayValueFor = {
                    return self.wrapPrice(Int($0 ?? 0))
                }
                $0.onChange {
                    let rounded = 50 * Int(round($0.value! / 50.0))
                    $0.value = Float(rounded)
                }
            }.cellSetup { cell, row in
                cell.slider.minimumValue = Float(self.MIN_BUDGET)
                cell.slider.maximumValue = Float(self.MAX_BUDGET)
            }
            <<< SliderRow("num_people") {
                $0.title = "People"
                $0.value = 2
                $0.steps = UInt(MAX_PEOPLE - MIN_PEOPLE)
                $0.displayValueFor = {
                    return "\(Int($0 ?? 0))"
                }
            }.cellSetup { cell, row in
                cell.slider.minimumValue = Float(self.MIN_PEOPLE)
                cell.slider.maximumValue = Float(self.MAX_PEOPLE)
            }
            <<< WeekendSelectionRow("weekend_travelling") { row in
                if let user = user, let dates = user.weekendDates {
                    let weekend = WeekendSelection(value: user.travelDates, dates: dates)
                    row.value = weekend
                }
            }
            
            <<< SegmentedRow<String>("leaveDay") {
                $0.title = "Leave on"
                $0.options = ["Thursday", "Friday", "Saturday"]
                $0.value = "Friday"
                }.onChange { row in
                    if self.formLoaded {
                        self.view.tintColor = UIColor.TMAColors.DarkTeal
                        let data = self.form.values()
                        let leaveDay = data["leaveDay"] as! String
                        self.user?.leaveDay = leaveDay.lowercased()
                        self.updateDates()
                        self.user?.leaveDate = 0
                        self.user?.returnDate = 0
                    }
            }

            <<< SegmentedRow<String>("returnDay") {
                $0.title = "Return on"
                $0.options = ["Sunday", "Monday", "Tuesday"]
                $0.value = "Sunday"
                }.onChange { row in
                    if self.formLoaded {
                        self.view.tintColor = UIColor.TMAColors.DarkTeal
                        let data = self.form.values()
                        let returnDay = data["returnDay"] as! String
                        self.user?.returnDay = returnDay.lowercased()
                        self.updateDates()
                        self.user?.leaveDate = 0
                        self.user?.returnDate = 0
                    }
            }
            
            <<< TextRow() {
                $0.title = "or pick your own dates"
            }
            
            <<< DateRow("leaveDate") {
                $0.title = "Leaving date"
                $0.value = Date(timeIntervalSince1970: leavingDate!)
            }
    
            <<< DateRow("returnDate") {
                $0.title = "Returning date"
                $0.value = Date(timeIntervalSince1970: returningDate!)
            }

            <<< SegmentedRow<String>("currency") {
                $0.title = "Currency"
                $0.options = ["EUR", "GBP", "USD"]
                $0.value = "EUR"
                }.onChange { row in
                    if self.formLoaded {
                        self.view.tintColor = UIColor.TMAColors.DarkTeal
                        // save data and re-render budget row so we get correct symbol
                        if let budgetRow = self.form.rowBy(tag: "total_budget") {
                            let data = self.form.values()
                            let currencyString = data["currency"] as! String
                            var currencyCode = "GBP"
                            switch (currencyString) {
                            case "EUR":
                                currencyCode = "EUR"
                                break
                            case "USD":
                                currencyCode = "USD"
                                break
                            case "GBP":
                                currencyCode = "GBP"
                                break
                            default:
                                currencyCode = "GBP"
                                break
                            }
                            
                            self.user?.currencyCode = currencyCode
                            budgetRow.updateCell()
                        }
                    }
                }
            
        +++ Section("Hotel Types")
            <<< SwitchRow("type_apartment") {
                $0.title = "Apartments"
        }
            <<< SwitchRow("type_hotels") {
                $0.title = "Hotels"
        }
            <<< SwitchRow("type_bnbs") {
                $0.title = "Bed & Breakfasts"
        }
            <<< SwitchRow("type_aparthotels") {
                $0.title = "Aparthotels"
        }
        
        renderData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Settings"
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // get data from form
        let data = form.values()
        
        let budget = Int(data["total_budget"] as! Float)
        let people = Int(data["num_people"] as! Float)
        let travelDates = (data["weekend_travelling"] as! WeekendSelection).value
        let currencyCode = data["currency"] as! String // == "EUR" ? "EUR" : "GBP"
        let hotelTypes = hotelTypesAsString(types: data)
        let leaveDay = data["leaveDay"] as! String
        let returnDay = data["returnDay"] as! String

        let leaveDate = data["leaveDate"] as! Date
        let returnDate = data["returnDate"] as! Date
        
        if settingsChanged(user: user!, budget: budget, people: people, travelDates: travelDates, hotelTypes: hotelTypes, leaveDay: leaveDay, returnDay: returnDay, leaveDate: Double(leaveDate.timeIntervalSince1970), returnDate: Double(returnDate.timeIntervalSince1970)) {
            // if changed, save to api
            user?.budget = budget
            user?.people = people
            user?.travelDates = travelDates
            user?.currencyCode = currencyCode
            user?.hotelTypes = hotelTypes
            user?.leaveDay = leaveDay.lowercased()
            user?.returnDay = returnDay.lowercased()
            user?.leaveDate = Double(leaveDate.timeIntervalSince1970)
            user?.returnDate = Double(returnDate.timeIntervalSince1970)
            
            saveChanges()
        }
        
    }
    
    func renderData() {
        if let user = user {
            var values: [String:Any?] = [
                "total_budget": Float(user.budget),
                "num_people": Float(user.people),
                "currency": user.currencyCode // == "GBP" ? "Pounds Sterling" : "Euros"
            ]
            if let weekendDates = user.weekendDates {
                values["weekend_travelling"] = WeekendSelection(value: user.travelDates, dates: weekendDates)
            } else {
                values["weekend_travelling"] = WeekendSelection(value: user.travelDates, dates: nil)
            }
            
            if (user.leaveDay != "") {
                values["leaveDay"] = user.leaveDay.capitalized
            } else {
                values["leaveDay"] = "friday".capitalized
            }
            if (user.returnDay != "") {
                values["returnDay"] = user.returnDay.capitalized
            } else {
                values["returnDay"] = "sunday".capitalized
            }
            
            form.setValues(values)
            form.setValues(hotelTypesAsBools(types: user.hotelTypes))
            formLoaded = true
        }
    }
    
    func settingsChanged(user: User, budget: Int, people: Int, travelDates: String, hotelTypes: String, leaveDay: String, returnDay: String, leaveDate: Double, returnDate: Double) -> Bool {
        var changed = false
        if (user.budget != budget) || (user.people != people) || (user.travelDates != travelDates) || (user.hotelTypes != hotelTypes) || (user.leaveDay != leaveDay) || (user.returnDay != returnDay) || (user.leaveDate != leaveDate) || (user.returnDate != returnDate) {
            changed = true
        }
        
        return changed
    }
    
    func saveChanges() {
        // send back up to API
        updateUserSettings(user: user!, sender: self, completion: { (error) in
            if let error = error {
                // TODO: handle error
                print("Error saving settings: \(error)")
            } else {
                // refresh destination cards based on new settings
                self.didChangeFilters(sender: self)
            }
        })
    }
    
    func hotelTypesAsBools(types: String) -> [String:Bool] {
        var bools: [String:Bool] = [
            "type_apartment": false,
            "type_hotels": false,
            "type_bnbs": false,
            "type_villas": false,
            "type_aparthotels": false,
            "type_condos": false,
            "type_cottages": false
        ]
        
        let types = types.split(separator: ",")
        for t in types {
            if t == "201" { bools["type_apartment"] = true }
            if t == "204" { bools["type_hotels"] = true }
            if t == "208" { bools["type_bnbs"] = true }
            if t == "219" { bools["type_aparthotels"] = true }
        }
        
        return bools
    }
    
    func hotelTypesAsString(types: [String:Any?]) -> String {
        var codes: [String] = []
        
        let apartments = types["type_apartment"] as? Bool
        let hotels = types["type_hotels"] as? Bool
        let bnbs = types["type_bnbs"] as? Bool
        let aparthotels = types["type_aparthotels"] as? Bool
        
        if apartments! { codes.append("201") }
        if hotels! { codes.append("204") }
        if bnbs! { codes.append("208") }
        if aparthotels! { codes.append("219") }
        
        if (!apartments! && !hotels! && !bnbs! && !aparthotels!) {
            codes.append("201")
        }
        
        return codes.joined(separator: ",")
    }
    
}
