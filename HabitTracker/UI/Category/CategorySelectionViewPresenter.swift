//
//  CategorySelectionViewPresenter.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 28.11.2025.
//

import UIKit

final class CategorySelectionViewPresenter {
    
    weak var viewController: CategorySelectionViewController?
    
    init(viewController: CategorySelectionViewController? = nil) {
        self.viewController = viewController
    }
}
