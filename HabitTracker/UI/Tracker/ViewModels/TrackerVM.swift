//
//  TrackerVM.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 12.11.2025.
//

import UIKit

struct TrackerVM: Identifiable {
    var id: UUID 
    var title: String
    var emoji: String
    var color: String
    var categoryID: UUID?
    var schedule: [Weekday]
}
