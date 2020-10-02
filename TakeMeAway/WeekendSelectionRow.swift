//
//  WeekendSelectionRow.swift
//  TakeMeAway
//
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim

import Foundation
import Eureka

final class WeekendSelectionRow: Row<WeekendSelectionCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WeekendSelectionCell>(nibName: "WeekendSelectionCell")
    }
}
