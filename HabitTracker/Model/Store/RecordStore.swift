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
            sectionNameKeyPath: "trackerID",
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
        recordCD.trackerID = Int32(vm.trackerID)

        do {
            try context.save()
            return true
        } catch {
           print(error.localizedDescription)
        }
        return false
    }
}

extension RecordStore {

    func completedDaysCount(for trackerID: Int) -> Int {
        let request = RecordCD.fetchRequest()
        request.predicate = NSPredicate(format: "trackerID == %d", trackerID)
        do {
            return try context.count(for: request)
        } catch {
            print("count error:", error)
            return 0
        }
    }

    func isCompletedToday(trackerID: Int, date: Date = Date()) -> Bool {
        let request = RecordCD.fetchRequest()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        request.predicate = NSPredicate(
            format: "trackerID == %d AND date >= %@ AND date < %@",
            trackerID,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.fetchLimit = 1

        do {
            return !(try context.fetch(request)).isEmpty
        } catch {
            print("fetch today error:", error)
            return false
        }
    }

    @discardableResult
    func createRecordForToday(trackerID: Int, date: Date = Date()) -> Bool {
        guard !isCompletedToday(trackerID: trackerID, date: date) else { return false }

        let recordCD = RecordCD(context: context)
        recordCD.date = date
        recordCD.trackerID = Int32(trackerID)

        do {
            try context.save()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    @discardableResult
    func deleteRecordForToday(trackerID: Int, date: Date = Date()) -> Bool {
        let request = RecordCD.fetchRequest()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        request.predicate = NSPredicate(
            format: "trackerID == %d AND date >= %@ AND date < %@",
            trackerID,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.fetchLimit = 1

        do {
            if let record = try context.fetch(request).first {
                context.delete(record)
                try context.save()
                return true
            }
            return false
        } catch {
            print("delete today error:", error)
            return false
        }
    }

    @discardableResult
    func toggleRecordForToday(trackerID: Int, date: Date = Date()) -> Bool {
        if isCompletedToday(trackerID: trackerID, date: date) {
            return deleteRecordForToday(trackerID: trackerID, date: date)
        } else {
            return createRecordForToday(trackerID: trackerID, date: date)
        }
    }
}

