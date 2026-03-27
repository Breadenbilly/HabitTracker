//
//  TrackerViewController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 31.10.2025.
//

import UIKit
import CoreData

final class TrackerViewController: UIViewController, UISearchResultsUpdating, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants

    var viewModel = TrackerViewModel()

    private enum Constants {
        static let largeTitleFontSize: CGFloat = 34
    }

    // MARK: - UI Components

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .label
        return picker
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Star")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("What do you want to track?", comment: "")
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(
            TrackerCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCollectionViewHeader.reuseIdentifier
        )
        return collectionView
    }()

    private lazy var floatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Filters", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()

    private lazy var throbber: UIActivityIndicatorView = {
        let throbber = UIActivityIndicatorView(style: .large)
        throbber.hidesWhenStopped = true
        return throbber
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        throbber.startAnimating()

        collectionView.dataSource = self
        collectionView.delegate = self

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 9
            layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }

        updateEmptyState()

        floatingButton.addTarget(self, action: #selector(filtersTapped), for: .touchUpInside)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.throbber.stopAnimating()
            // для проверки
        }
    }

    // MARK: - Setup

    private func setupUI() {
        setupConstraints()
        setupNavigationBar()
        setupBarButtonItems()
    }

    private func setupNavigationBar() {
        title = NSLocalizedString("Trackers", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupBarButtonItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(resource: .add),
            style: .plain,
            target: self,
            action: #selector(addNewHabit)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        NSLayoutConstraint.activate([datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 118)])
    }

    private func setupConstraints() {
        [imageView, label, datePicker, collectionView, floatingButton, throbber].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            floatingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floatingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            floatingButton.heightAnchor.constraint(equalToConstant: 50),
            floatingButton.widthAnchor.constraint(equalToConstant: 114),

            throbber.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            throbber.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }

    // MARK: - Actions

    @objc private func addNewHabit() {
        let addNewHabitViewController = AddNewHabitViewController()

        addNewHabitViewController.onTrackerCreated = { [weak self] in
            self?.collectionView.reloadData()
            self?.updateEmptyState()
        }

        let navigationController = UINavigationController(rootViewController: addNewHabitViewController)
        navigationController.modalPresentationStyle = .pageSheet

        present(navigationController, animated: true)
    }

    @objc private func filtersTapped() {
        let vc = FiltersViewController()
        vc.selectedFilter = viewModel.currentFilter

        vc.onFilterSelected = { [weak self] filter in
            guard let self else { return }
            self.viewModel.currentFilter = filter
            TrackerStore.shared.applyFilter(filter, date: self.datePicker.date)
            self.collectionView.reloadData()
            self.updateEmptyState()

        }

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: - Search

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        print(text)
    }

    // MARK: - collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return TrackerStore.shared.sectionsCount()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TrackerStore.shared.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! TrackerCollectionViewCell

        let trackerVM = TrackerStore.shared.fetchTrackerWithIndexPath(indexPath)

        let days = RecordStore.shared.completedDaysCount(for: trackerVM.id)
        let isCompletedToday = RecordStore.shared.isCompletedToday(trackerID: trackerVM.id)
        let isPinned = TrackerStore.shared.isTrackerPinned(id: trackerVM.id) // ← добавить эту строку

        cell.configure(
            emoji: trackerVM.emoji,
            title: trackerVM.title,
            days: days,
            color: color(from: trackerVM.color),
            isCompleted: isCompletedToday,
            isPinned: isPinned
        )

        cell.onPlusTap = { [weak collectionView] in
            _ = RecordStore.shared.toggleRecordForToday(trackerID: trackerVM.id)
            collectionView?.reloadItems(at: [indexPath])
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width
        let spacing: CGFloat = 9
        let cellWidth = (availableWidth - spacing) / 2
        return CGSize(width: cellWidth, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCollectionViewHeader.reuseIdentifier,
            for: indexPath
        ) as! TrackerCollectionViewHeader

        let rawName = TrackerStore.shared.fetchedResultsController.sections?[indexPath.section].name ?? ""

        let displayName: String
        if rawName == "0" {
            displayName = NSLocalizedString("Pinned", comment: "")
        } else {
            displayName = String(rawName.dropFirst(2)) // убираем "1_"
        }

        header.configure(title: displayName)
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }


    private func updateEmptyState() {
        let hasTrackers = TrackerStore.shared.trackersCount() > 0
        collectionView.backgroundColor = hasTrackers ? .systemBackground : .clear
        imageView.isHidden = hasTrackers
        label.isHidden = hasTrackers
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else { return nil }

        let trackerVM = TrackerStore.shared.fetchTrackerWithIndexPath(indexPath)
        let trackerID = trackerVM.id
        let isPinned = TrackerStore.shared.isTrackerPinned(id: trackerID)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }

            let pin = UIAction(
                title: isPinned
                    ? NSLocalizedString("Unpin", comment: "")
                    : NSLocalizedString("Pin", comment: ""),
                image: isPinned
                    ? UIImage(systemName: "pin.slash")
                    : UIImage(systemName: "pin")
            ) { [weak self] _ in
                isPinned
                    ? TrackerStore.shared.unpinTracker(id: trackerID)
                    : TrackerStore.shared.pinTracker(id: trackerID)
                self?.collectionView.reloadData()
            }

            let edit = UIAction(
                title: NSLocalizedString("Edit", comment: ""),
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                self?.openEditScreen(for: trackerID)
            }
            
            let delete = UIAction(
                title: NSLocalizedString("Delete", comment: ""),
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.deleteTracker(id: trackerID)
            }

            return UIMenu(children: [pin, edit, delete])
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {

        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = cell.containerView.backgroundColor ?? .clear
        parameters.visiblePath = UIBezierPath(
            roundedRect: cell.containerView.bounds,
            cornerRadius: 16
        )

        return UITargetedPreview(view: cell.containerView, parameters: parameters)
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {

        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(
            roundedRect: cell.containerView.bounds,
            cornerRadius: 16
        )

        return UITargetedPreview(view: cell.containerView, parameters: parameters)
    }

    private func deleteTracker(id trackerID: UUID) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("Delete tracker?", comment: ""),
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [weak self] _ in
            TrackerStore.shared.deleteTracker(id: trackerID)
            self?.collectionView.reloadData()
            self?.updateEmptyState()
        })

        present(alert, animated: true)
    }

    private func openEditScreen(for trackerID: UUID) {
        guard let trackerCD = TrackerStore.shared.fetchTrackerCD(id: trackerID),
              let id = trackerCD.id else { return }

        let schedule = (trackerCD.schedule as? [Int])?.compactMap { Weekday(rawValue: $0) } ?? []

        let trackerVM = TrackerVM(
            id: id,
            title: trackerCD.title ?? "",
            emoji: trackerCD.emoji ?? "",
            color: trackerCD.color ?? "",
            categoryID: trackerCD.category?.id,
            schedule: schedule
        )

        let vc = AddNewHabitViewController()
        vc.editingTracker = trackerVM
        vc.onTrackerCreated = { [weak self] in
            self?.collectionView.reloadData()
            self?.updateEmptyState()
        }

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: - Helpers
    private func color(from hexString: String) -> UIColor {
        // Trim whitespace and leading '#'
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }

        // Support short RGB (e.g., FFF) by expanding to 6 chars
        if hex.count == 3 {
            let r = hex[hex.startIndex]
            let g = hex[hex.index(hex.startIndex, offsetBy: 1)]
            let b = hex[hex.index(hex.startIndex, offsetBy: 2)]
            hex = String([r, r, g, g, b, b])
        }
        // Expect 6 or 8 characters (RRGGBB or RRGGBBAA)
        guard hex.count == 6 || hex.count == 8 else {
            return .systemBlue // Fallback color
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        let r, g, b, a: CGFloat
        if hex.count == 8 {
            let rComp = (rgbValue & 0xFF000000) >> 24
            let gComp = (rgbValue & 0x00FF0000) >> 16
            let bComp = (rgbValue & 0x0000FF00) >> 8
            let aComp = (rgbValue & 0x000000FF)

            r = CGFloat(rComp) / 255.0
            g = CGFloat(gComp) / 255.0
            b = CGFloat(bComp) / 255.0
            a = CGFloat(aComp) / 255.0
        } else {
            let rComp = (rgbValue & 0xFF0000) >> 16
            let gComp = (rgbValue & 0x00FF00) >> 8
            let bComp = (rgbValue & 0x0000FF)

            r = CGFloat(rComp) / 255.0
            g = CGFloat(gComp) / 255.0
            b = CGFloat(bComp) / 255.0
            a = 1.0
        }

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

