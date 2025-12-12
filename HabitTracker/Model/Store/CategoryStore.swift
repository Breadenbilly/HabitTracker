//
//  CategoryStore.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 12.11.2025.
//

import CoreData

final class CategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = CategoryStore()
    
    var context: NSManagedObjectContext {
        CoreDataManager.shared.persistentContainer.viewContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<CategoryCD> = {
        let fetchedRequest = CategoryCD.fetchRequest()
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchedRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch entities: \(error)")
        }
        
        return fetchedResultsController
    }()
    
    func fetchCategories() -> [CategoryVM] {
        fetchedResultsController.fetchedObjects
        return []
    }
    
    @discardableResult
    func createCategory(_ vm: CategoryVM) -> Bool {
        let categoryCD = CategoryCD(context: context)
        categoryCD.title = vm.title
        categoryCD.id = vm.id
        
        do {
            try context.save()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
