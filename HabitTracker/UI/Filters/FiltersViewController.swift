//
//  FiltersViewController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 20.3.2026.
//
import UIKit
import SnapKit

enum TrackerFilter: String, CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all:         return NSLocalizedString("All trackers", comment: "")
        case .today:       return NSLocalizedString("Trackers for today", comment: "")
        case .completed:   return NSLocalizedString("Completed", comment: "")
        case .uncompleted: return NSLocalizedString("Not Completed", comment: "")
        }
    }
}

final class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedFilter: TrackerFilter = .today
    var onFilterSelected: ((TrackerFilter) -> Void)?

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)  // ← insetGrouped
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .systemBackground
        tv.register(FiltersViewCell.self, forCellReuseIdentifier: FiltersViewCell.reuseIdentifier)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Filters", comment: "")
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FiltersViewCell.reuseIdentifier,
            for: indexPath
        ) as! FiltersViewCell

        let filter = TrackerFilter.allCases[indexPath.row]
        cell.configure(title: filter.title, isSelected: filter == selectedFilter)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = TrackerFilter.allCases[indexPath.row]
        tableView.reloadData()
        onFilterSelected?(selectedFilter)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
