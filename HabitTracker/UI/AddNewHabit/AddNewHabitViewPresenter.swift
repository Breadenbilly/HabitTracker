//
//  AddNewHabitViewPresenter.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 2.11.2025.
//
import UIKit

final class AddNewHabitViewPresenter {
   
    weak var viewController: AddNewHabitViewController?
    
    init(viewController: AddNewHabitViewController? = nil) {
        self.viewController = viewController
        CategoryCD.fetchRequest()
    }
}
