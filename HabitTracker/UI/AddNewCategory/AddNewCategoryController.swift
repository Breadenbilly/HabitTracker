//
//  AddNewCategoryController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 11.12.2025.
//

import UIKit
import SnapKit

final class AddNewCategoryController: UIViewController {
    
    private let viewModel = AddNewCategoryViewModel()
    
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
        button.layer.cornerRadius = 16
        button.backgroundColor = .grayFontTextEditor
        button.isEnabled = false
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
        view.backgroundColor = .white
        textView.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        doneButton.addAction(
                UIAction { [weak self] _ in
                    self?.saveCategory()
                },
                for: .touchUpInside
            )
        
            updateDoneButtonAppearance()
    }
    
    @objc private func textDidChange() {
        updateDoneButtonAppearance()
    }
    
    private func updateDoneButtonAppearance() {
        let isEmpty = (textView.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

        doneButton.backgroundColor = isEmpty ? .grayFontTextEditor : .black
        doneButton.isEnabled = !isEmpty
    }
    
    func setupConstraints() {
        
        view.addSubview(containerView)
        containerView.addSubview(textView)
        view.addSubview(doneButton)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.height.equalTo(75)
        }
        
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(60)
            make.leading.trailing.equalTo(view).inset(20)
        }
    }
    
    private func saveCategory() {
        guard
            let title = textView.text?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !title.isEmpty
        else { return }

        let newCategory = CategoryVM(
            id: UUID(),
            title: title
        )

        let created = CategoryStore.shared.createCategory(newCategory)

        if created {
            navigationController?.popViewController(animated: true)
        }
    }
}
