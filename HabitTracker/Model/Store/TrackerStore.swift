//
//  TrackerStore.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 12.11.2025.
//
import CoreData
import UIKit

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = TrackerStore()
    
    var context: NSManagedObjectContext {
        CoreDataManager.shared.persistentContainer.viewContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {
        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch() // perform запускает fetchResultController
        } catch {
            print("Failed to fetch: \(error)")
        }
        return fetchedResultsController
    }()
    
   
    func sectionsConut() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func trackersCount() -> Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func fetchTrackers() -> [TrackerVM] {
        fetchedResultsController.fetchedObjects
        return []
    }
    
    func fetchTrackerWithIndexPath(_ indexPath: IndexPath) -> TrackerVM {
        let trackerCD = fetchedResultsController.object(at: indexPath)
        let trackerVM = TrackerVM(
            id: Int(trackerCD.id),
            title: trackerCD.title ?? "",
            emoji: trackerCD.emoji ?? "",
            color: (trackerCD.color ?? "")
        )
        return trackerVM
    }

    
    @discardableResult
    func createTracker(_ vm: TrackerVM, categoryID: UUID) -> Bool {
        let trackerCD = TrackerCD(context: context)
        trackerCD.id = Int32(vm.id)
        trackerCD.title = vm.title
        trackerCD.emoji = vm.emoji
        trackerCD.color = vm.color
        
        // Найти категорию по ID
        let fetchRequest: NSFetchRequest<CategoryCD> = CategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryID as CVarArg)
        
        do {
            let categories = try context.fetch(fetchRequest)
            if let category = categories.first {
                trackerCD.category = category
            }
            
            try context.save()
            return true
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
    }
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
    }
}
