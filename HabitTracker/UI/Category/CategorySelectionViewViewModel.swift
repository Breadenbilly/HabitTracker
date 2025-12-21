//
//  CategorySelectionViewViewModel.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 28.11.2025.
//

import Foundation

final class CategorySelectionViewModel {

    private let store: CategoryStore

    private(set) var categories: [CategoryVM] = []
    private(set) var selectedCategoryIndex: Int?

    var onChange: (() -> Void)?
    var onSelectedCategory: ((CategoryVM) -> Void)? 

    init(store: CategoryStore = .shared) {
        self.store = store
    }

    func load() {
        categories = store.fetchCategories()
        onChange?()
    }

    func numberOfRows() -> Int { categories.count }

    func category(at index: Int) -> CategoryVM { categories[index] }

    func selectCategory(at index: Int) {
        selectedCategoryIndex = index
        onChange?()
    }

    func isSelected(at index: Int) -> Bool {
        selectedCategoryIndex == index
    }

    func doneTapped() {
        guard let idx = selectedCategoryIndex else { return }
        onSelectedCategory?(categories[idx])
    }
}
