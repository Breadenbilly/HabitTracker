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
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "sectionIdentifier",
            cacheName: nil
        )

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error.localizedDescription)")
        }

        return fetchedResultsController
    }()

    func sectionsCount() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func trackersCount() -> Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func fetchTrackers() -> [TrackerVM] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }

        return objects.compactMap { trackerCD in
            guard let id = trackerCD.id else { return nil }

            return TrackerVM(
                id: id,
                title: trackerCD.title ?? "",
                emoji: trackerCD.emoji ?? "",
                color: trackerCD.color ?? "",
                categoryID: trackerCD.category?.id,
                schedule: (trackerCD.schedule as? [Int])?.compactMap { Weekday(rawValue: $0) } ?? []
            )
        }
    }

    func fetchTrackerWithIndexPath(_ indexPath: IndexPath) -> TrackerVM {
        let trackerCD = fetchedResultsController.object(at: indexPath)
        guard let id = trackerCD.id else { fatalError("TrackerCD.id is missing") }

        let schedule = (trackerCD.schedule as? [Int])?.compactMap { Weekday(rawValue: $0) } ?? []

        return TrackerVM(
            id: id,
            title: trackerCD.title ?? "",
            emoji: trackerCD.emoji ?? "",
            color: trackerCD.color ?? "",
            categoryID: trackerCD.category?.id,
            schedule: schedule
        )
    }

    @discardableResult
    func createTracker(_ vm: TrackerVM, categoryID: UUID) -> Bool {
        let trackerCD = TrackerCD(context: context)
        trackerCD.id = vm.id
        trackerCD.title = vm.title
        trackerCD.emoji = vm.emoji
        trackerCD.color = vm.color
        trackerCD.schedule = vm.schedule.map { $0.rawValue } as NSArray

        let fetchRequest: NSFetchRequest<CategoryCD> = CategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryID as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            guard let category = try context.fetch(fetchRequest).first else {
                context.delete(trackerCD)
                print("Category not found")
                return false
            }

            trackerCD.category = category
            try context.save()
            return true
        } catch {
            context.delete(trackerCD)
            print("Failed to create tracker: \(error.localizedDescription)")
            return false
        }
    }

    func deleteTracker(id: UUID) {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            if let object = try context.fetch(request).first {
                context.delete(object)
                try context.save()
            }
        } catch {
            print("Failed to delete tracker: \(error.localizedDescription)")
        }
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

    func pinTracker(id: UUID) {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let tracker = try? context.fetch(request).first else { return }
        tracker.isPinned = true
        try? context.save()
    }

    func unpinTracker(id: UUID) {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let tracker = try? context.fetch(request).first else { return }
        tracker.isPinned = false
        try? context.save()
    }

    func isTrackerPinned(id: UUID) -> Bool {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return (try? context.fetch(request).first?.isPinned) ?? false
    }

    func fetchTrackerCD(id: UUID) -> TrackerCD? {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    @discardableResult
    func updateTracker(_ vm: TrackerVM, categoryID: UUID) -> Bool {
        guard let trackerCD = fetchTrackerCD(id: vm.id) else { return false }

        let fetchRequest: NSFetchRequest<CategoryCD> = CategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryID as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            guard let category = try context.fetch(fetchRequest).first else { return false }
            trackerCD.title = vm.title
            trackerCD.emoji = vm.emoji
            trackerCD.color = vm.color
            trackerCD.category = category
            trackerCD.schedule = vm.schedule.map { $0.rawValue } as NSArray
            try context.save()
            return true
        } catch {
            print("Failed to update tracker: \(error.localizedDescription)")
            return false
        }
    }

    func applyFilter(_ filter: TrackerFilter, date: Date) {
        switch filter {
        case .all:
            fetchedResultsController.fetchRequest.predicate = nil

        case .today:
            fetchedResultsController.fetchRequest.predicate = nil

        case .completed:
            let ids = RecordStore.shared.completedTodayIDs(date: date)
            fetchedResultsController.fetchRequest.predicate = ids.isEmpty
                ? NSPredicate(value: false)
                : NSPredicate(format: "id IN %@", ids as CVarArg)

        case .uncompleted:
            let ids = RecordStore.shared.completedTodayIDs(date: date)
            fetchedResultsController.fetchRequest.predicate = ids.isEmpty
                ? nil
                : NSPredicate(format: "NOT (id IN %@)", ids as CVarArg)
        }

        try? fetchedResultsController.performFetch()
    }
}

extension TrackerCD {
    @objc var sectionIdentifier: String {
        isPinned ? "0" : "1_\(category?.title ?? "")"
    }
}
