//
//  Models.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 16.11.2025.
//

import UIKit

enum Weekday: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var shortTitle: String {
        let key: String
        
        switch self {
        case .monday:    key = "Mon"
        case .tuesday:   key = "Tue"
        case .wednesday: key = "Wed"
        case .thursday:  key = "Thu"
        case .friday:    key = "Fri"
        case .saturday:  key = "Sat"
        case .sunday:    key = "Sun"
        }
        
        return NSLocalizedString(key, comment: "Short weekday title")
    }
}
