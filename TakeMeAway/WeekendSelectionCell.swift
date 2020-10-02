//
//  WeekendSelectionCell.swift
//  TakeMeAway
//
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim

import UIKit
import Eureka

struct WeekendSelection: Equatable {
    let value: String
    let dates: WeekendDates?
}

func ==(lhs: WeekendSelection, rhs: WeekendSelection) -> Bool {
    return lhs.value == rhs.value
}

var user: User?

final class WeekendSelectionCell: Cell<WeekendSelection>, CellType {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var thisWeekendLabel: UILabel!
    @IBOutlet weak var nextWeekendLabel: UILabel!
    @IBOutlet weak var twoWeekendLabel: UILabel!
    
    
    @IBAction func userDidChangeSelection(_ sender: Any) {
        if let seg = sender as? UISegmentedControl {
            let oldVal = self.row.value!
            
            if (seg.selectedSegmentIndex == 0) {
                self.row.value = WeekendSelection(value: "thisweekend", dates: oldVal.dates)
            } else if (seg.selectedSegmentIndex == 1) {
                self.row.value = WeekendSelection(value: "nextweekend", dates: oldVal.dates)
            } else if (seg.selectedSegmentIndex == 2) {
                self.row.value = WeekendSelection(value: "twoweekends", dates: oldVal.dates)
            }
            UpdateDatesDisplay()
        }
    }
    
    
    var isLoaded  = false
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        
        let name = Notification.Name(rawValue: "UpdateDatesDisplay")
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateDatesDisplay), name: name, object: nil)
        
        // we do not want our cell to be selected in this case. If you use such a cell in a list then you might want to change this.
        selectionStyle = .none
        
        titleLabel.text = "Travelling"
        thisWeekendLabel.text = ""
        nextWeekendLabel.text = ""
        twoWeekendLabel.text = ""

        // specify the desired height for our cell
        height = { return 74 }
        
        isLoaded = true
    }
    
    override func update() {
        super.update()
        
        // we do not want to show the default UITableViewCell's textLabel
        textLabel?.text = nil
        
        // get the value from our row
        guard let weekend = row.value else { return }
        
        if (weekend.value == "twoweekends") {
            segmentedControl.selectedSegmentIndex = 2
        } else if weekend.value == "nextweekend" {
            // select next weekend
            segmentedControl.selectedSegmentIndex = 1
        } else {
            // select this weekend
            segmentedControl.selectedSegmentIndex = 0
        }
        
        UpdateDatesDisplay()
    }
    
    @objc func UpdateDatesDisplay() {

        if (self.isLoaded) {
            user = currentUser(sender: self)

            let currentDate = Date()
            var leaveDay = DateComponents(),
            returnDay = DateComponents()

            // we need the day selector data too
            if (user?.leaveDay == "thursday") {
                leaveDay.weekday = 5 // Thursday
            } else if (user?.leaveDay == "friday") {
                leaveDay.weekday = 6
            } else {
                leaveDay.weekday = 7
            }

            if (user?.returnDay == "sunday") {
                returnDay.weekday = 1 // sunday
            } else if (user?.returnDay == "monday") {
                returnDay.weekday = 2
            } else {
                returnDay.weekday = 3
            }

            let leavingDay = Calendar.current.nextDate(after: currentDate, matching: leaveDay, matchingPolicy: .nextTime)
            let returningDay = Calendar.current.nextDate(after: leavingDay!, matching: returnDay, matchingPolicy: .nextTime)

            var offsetLeavingDay = Calendar.current.date(byAdding: .day, value: 0, to: leavingDay!)
            var offsetReturningDay = Calendar.current.date(byAdding: .day, value: 0, to: returningDay!)
            
            // the slow way because Swift blows
            var label = offsetLeavingDay?.dayAsString()
            label = label! + " "
            label = label! + (offsetLeavingDay?.monthAsString())!
            label = label! + "-"
            label = label! + (offsetReturningDay?.dayAsString())!
            label = label! + " "
            label = label! + (offsetReturningDay?.monthAsString())!

            thisWeekendLabel.text = label

            offsetLeavingDay = Calendar.current.date(byAdding: .day, value: 7, to: leavingDay!)
            offsetReturningDay = Calendar.current.date(byAdding: .day, value: 7, to: returningDay!)
            
            label = offsetLeavingDay?.dayAsString()
            label = label! + " "
            label = label! + (offsetLeavingDay?.monthAsString())!
            label = label! + "-"
            label = label! + (offsetReturningDay?.dayAsString())!
            label = label! + " "
            label = label! + (offsetReturningDay?.monthAsString())!

            nextWeekendLabel.text = label

            offsetLeavingDay = Calendar.current.date(byAdding: .day, value: 14, to: leavingDay!)
            offsetReturningDay = Calendar.current.date(byAdding: .day, value: 14, to: returningDay!)
            
            label = offsetLeavingDay?.dayAsString()
            label = label! + " "
            label = label! + (offsetLeavingDay?.monthAsString())!
            label = label! + "-"
            label = label! + (offsetReturningDay?.dayAsString())!
            label = label! + " "
            label = label! + (offsetReturningDay?.monthAsString())!

            twoWeekendLabel.text = label
        }
    }
    

}

extension Date {
    func monthAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMM")
        return df.string(from: self)
    }
    
    func dayAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("d")
        return df.string(from: self)
    }
}
