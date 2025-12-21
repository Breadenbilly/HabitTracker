//
//  CategorySelectionViewController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 13.11.2025.
//
import UIKit
import SnapKit

final class CategorySelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let viewModel = CategorySelectionViewModel()
    var onCategoryPicked: ((CategoryVM) -> Void)?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Star")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Habits and events can be grouped together by meaning", comment: "")
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Add category", comment: ""), for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addAction(UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(AddNewCategoryController(), animated: true)
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Category", comment: "")
        view.backgroundColor = .systemBackground
        setupConstraints()
        bindViewModel()
        viewModel.load()
        
        doneButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.doneTapped()
        }, for: .touchUpInside)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }
    
    func setupConstraints() {
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(doneButton)
        view.addSubview(addCategoryButton)
        view.addSubview(tableView)
        
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(80)
            make.centerX.equalTo(view)
            make.top.equalTo(view).inset(346)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view).inset(60)
        }
        
        doneButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view).inset(50)
            make.height.equalTo(60)
        }
        
        addCategoryButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(doneButton.snp.top).inset(-12)
            make.height.equalTo(60)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.bottom.equalTo(addCategoryButton.snp.top).offset(-16)
        }
        
    }
    
   
    
    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onSelectedCategory = { [weak self] category in
            self?.onCategoryPicked?(category)
            self?.navigationController?.popViewController(animated: true)
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryTableViewCell else {
            return UITableViewCell()
        }

        let vm = viewModel.category(at: indexPath.row)
        let isSelected = viewModel.isSelected(at: indexPath.row)
        cell.configure(title: vm.title, isSelected: isSelected)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
}
