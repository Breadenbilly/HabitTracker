//
//  CategorySelectionViewController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 13.11.2025.
//
import UIKit
import SnapKit

final class CategorySelectionViewController: UIViewController {
    
    private let presenter: CategorySelectionViewPresenter
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
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
    
    init(presenter: CategorySelectionViewPresenter) {
        self.presenter = presenter
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
    }
    
    func setupConstraints() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(label)
        scrollView.addSubview(addCategoryButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(80)
            make.centerX.equalTo(scrollView.contentLayoutGuide)
            make.top.equalTo(view).inset(346)
            
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(60)
        }
        
        addCategoryButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view).inset(50)
            make.height.equalTo(60)
        }
    }
}

