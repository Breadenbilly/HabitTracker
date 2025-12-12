//
//  RecordStore.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 18.11.2025.
//

import CoreData

final class RecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = RecordStore()
    
    
    
    var context: NSManagedObjectContext {
        CoreDataManager.shared.persistentContainer.viewContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<RecordCD> = {
        let fetchedRequest = RecordCD.fetchRequest()
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: "trackerID", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchedRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "record.trackerID",
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
    
    func fetchTrackers() -> [RecordVM] {
        fetchedResultsController.fetchedObjects
        return []
    }
    
    @discardableResult
    func createRecord(_ vm: RecordVM) -> Bool {
        let recordCD = RecordCD(context: context)
        recordCD.date = vm.date
        recordCD.trackerID = vm.trackerID
        
        do {
            try context.save()
            return true
        } catch {
           print(error.localizedDescription)
        }
        return false
    }
    
    
}

