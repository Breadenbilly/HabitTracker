//
//  AddNewCategoryController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 11.12.2025.
//

import UIKit
import SnapKit

final class AddNewCategoryController: UIViewController {
    
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayBackground.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let textView: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Type in catergory name", comment: "")
        textField.textAlignment = .left
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        return textField
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .grayFontTextEditor
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Init (programmatic)
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Add Category", comment: "")
        setupConstraints()
    }
    
    func setupConstraints() {
        
        view.addSubview(containerView)
        containerView.addSubview(textView)
        view.addSubview(doneButton)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(16)
            make.top.equalTo(view).offset(24)
            make.height.equalTo(75)
        }
        
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(16)
            make.top.bottom.equalTo(26)
        }
        
        
    }
    
    
}
