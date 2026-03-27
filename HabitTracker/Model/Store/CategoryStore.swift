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

    func deleteCategory(id: UUID) {
        let request: NSFetchRequest<CategoryCD> = CategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            if let object = try context.fetch(request).first {
                context.delete(object)
                try context.save()
            }
        } catch {
            print("Failed to delete category: \(error.localizedDescription)")
        }
    }

    func updateCategory(id: UUID, newTitle: String) {
        let request: NSFetchRequest<CategoryCD> = CategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            if let object = try context.fetch(request).first {
                object.title = newTitle
                try context.save()
            }
        } catch {
            print("Failed to update category: \(error.localizedDescription)")
        }
    }

    func fetchCategory(by id: UUID) -> CategoryVM? {
        let request: NSFetchRequest<CategoryCD> = CategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        guard let object = try? context.fetch(request).first else { return nil }
        return CategoryVM(id: object.id ?? UUID(), title: object.title ?? "")
    }

}
