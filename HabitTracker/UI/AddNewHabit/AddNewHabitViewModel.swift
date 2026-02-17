//
//  AddNewHabitViewModel.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 2.11.2025.
//
import Foundation

final class AddNewHabitViewModel {

    private(set) var selectedDays: [Weekday] = [] {

        didSet {
            onSelectedDaysChanged?(selectedDays)
        }
    }

    var onSelectedDaysChanged: (([Weekday]) -> Void)?

    func setSelectedDays(_ days: [Weekday]) {
        selectedDays = days
    }

// MARK: - Category

    private(set) var selectedCategory: CategoryVM? {
        didSet {
            onSelectedCategoryChanged?(selectedCategory)
        }
    }

    var onSelectedCategoryChanged: ((CategoryVM?) -> Void)?

    func setSelectedCategory(_ category: CategoryVM?) {
        selectedCategory = category
    }
    
    private(set) var selectedEmoji: String? {
            didSet { onSelectedEmojiChanged?(selectedEmoji) }
        }
        var onSelectedEmojiChanged: ((String?) -> Void)?

        func setSelectedEmoji(_ emoji: String?) {
            selectedEmoji = emoji
        }
}
