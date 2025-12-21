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
            sectionNameKeyPath: nil, // почему??
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
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch categories: \(error.localizedDescription)")
        }
        
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return objects.map { categoryCD in
            CategoryVM(
                id: categoryCD.id ?? UUID(),
                title: categoryCD.title ?? ""
            )
        }
    }
    
    
    @discardableResult
    func createCategory(_ vm: CategoryVM) -> Bool {
        let categoryCD = CategoryCD(context: context)
        categoryCD.id = vm.id
        categoryCD.title = vm.title
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to save category: \(error.localizedDescription)")
            return false
        }
    }
}
