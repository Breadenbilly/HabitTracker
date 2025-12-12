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
        var trackerCD = fetchedResultsController.object(at: indexPath)
        var trackerVM = TrackerVM(
            id: Int(trackerCD.id),
            title: trackerCD.title ?? "",
            emoji: trackerCD.emoji ?? "",
            color: trackerCD.color as? UIColor ?? .grayBackground
        )
        return trackerVM
    }

    
    @discardableResult
    func createTracker(_ vm: TrackerVM) -> Bool {
        let trackerCD = TrackerCD(context: context)
        trackerCD.id = Int16(vm.id)
        trackerCD.title = vm.title
        trackerCD.emoji = vm.emoji
        trackerCD.color = vm.color
        
        do {
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
