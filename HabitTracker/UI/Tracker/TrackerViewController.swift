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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 9
            layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
        updateEmptyState()
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
    }
    
    private func setupBarButtonItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(resource: .add),
            style: .plain,
            target: self,
            action: #selector(addNewHabit)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        NSLayoutConstraint.activate([datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 120)])
    }
    
    private func setupConstraints() {
        [imageView, label, datePicker, collectionView, floatingButton].forEach {
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
            floatingButton.widthAnchor.constraint(equalToConstant: 114)
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
    
    // MARK: - Search
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        print(text)
    }
    
    // MARK: - collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return TrackerStore.shared.sectionsConut()
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

        cell.configure(
            emoji: trackerVM.emoji,
            title: trackerVM.title,
            days: days,
            color: color(from: trackerVM.color),
            isCompleted: isCompletedToday
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
        
        header.configure(title: TrackerStore.shared.fetchedResultsController.sections?[indexPath.section].name ?? "")
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    private func updateEmptyState() {
        let hasTrackers = TrackerStore.shared.trackersCount() > 0
        collectionView.backgroundColor = hasTrackers ? .white : .clear
        imageView.isHidden = hasTrackers
        label.isHidden = hasTrackers
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
            r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgbValue & 0x000000FF) / 255.0
        } else {
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        }

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

