//
//  AddNewHabitViewController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 31.10.2025.
//


import UIKit
import SnapKit

final class AddNewHabitViewController: UIViewController,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout {

    private let addNewHabitViewModel = AddNewHabitViewModel()

    let colors = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4", "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC", "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]

    var selectedColor: String?

    var selectedColorIndexPath: IndexPath?

    let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]

    var selectedEmoji: String?

    var selectedEmojiIndexPath: IndexPath?

    var onTrackerCreated: (() -> Void)?

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Type tracker's name", comment: "")
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayBackground.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .separator
        return separator
    }()
    
    // MARK: - Stacks: Category
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Category", comment: "")
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private lazy var categoryValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .grayFontTextEditor
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var categoryVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .grayFontTextEditor
        return imageView
    }()
    
    private lazy var categoryFinalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        return stackView
    }()
    
    // MARK: - Stacks: Schedule
    
    private lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Schedule", comment: "")
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private lazy var scheduleValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .grayFontTextEditor
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var scheduleLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var scheduleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .grayFontTextEditor
        return imageView
    }()
    
    private lazy var scheduleFinalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        return stackView
    }()
    // MARK: - Emoji

    private(set) lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        collectionView.register(
            CollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionViewHeader.reuseIdentifier
        )
        return collectionView
    }()

    // MARK: - Stacks : Colors

    private(set) lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        collectionView.register(
            CollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionViewHeader.reuseIdentifier
        )
        return collectionView
    }()
    // MARK: - Stacks: Bottom
    
    private lazy var finalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .grayBackground.withAlphaComponent(0.3)
        stackView.layer.cornerRadius = 16
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .systemGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("New habit", comment: "")
        navigationItem.largeTitleDisplayMode = .never
        addNewHabitViewModel.onSelectedDaysChanged = { [weak self] days in
            self?.updateScheduleLabel(selectedDays: days)
            self?.validateForm()
        }
        addNewHabitViewModel.onSelectedCategoryChanged = { [weak self] category in
            self?.updateCategoryLabel(selectedCategory: category)
            self?.validateForm()
        }
        setupConstraints()
        setupGestures()
        updateScheduleLabel(selectedDays: [])
        updateCategoryLabel(selectedCategory: nil)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        categoryFinalStackView.isUserInteractionEnabled = true
        let categoryTap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryFinalStackView.addGestureRecognizer(categoryTap)
        
        scheduleLabelStackView.isUserInteractionEnabled = true
        let scheduleTap = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
        scheduleLabelStackView.addGestureRecognizer(scheduleTap)
    }
    
    @objc private func categoryTapped() {
        let vc = CategorySelectionViewController()

        vc.onCategoryPicked = { [weak self] category in
            self?.addNewHabitViewModel.setSelectedCategory(category)
        }

        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func scheduleTapped() {
        let vc = ScheduleSelectionViewController()
        vc.preselectedDays = addNewHabitViewModel.selectedDays

        vc.onDone = { [weak self] days in
            self?.addNewHabitViewModel.setSelectedDays(days)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func setupConstraints() {
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view)
        }
        
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        scrollView.addSubview(textFieldView)
        textFieldView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(16)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(24)
            make.height.equalTo(75)
        }
        
        textFieldView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(textFieldView).inset(16)
            make.centerY.equalTo(textFieldView)
        }
        
        scrollView.addSubview(finalStackView)
        finalStackView.snp.makeConstraints { make in
            make.top.equalTo(textFieldView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(16)
            make.height.equalTo(150)
        }
        
        categoryVerticalStackView.addArrangedSubview(categoryLabel)
        categoryVerticalStackView.addArrangedSubview(categoryValueLabel)
        categoryFinalStackView.addArrangedSubview(categoryVerticalStackView)
        categoryFinalStackView.addArrangedSubview(categoryImageView)
        
        categoryImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        categoryValueLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel).offset(24)
        }
        
        scheduleLabelStackView.addArrangedSubview(scheduleLabel)
        scheduleLabelStackView.addArrangedSubview(scheduleValueLabel)
        scheduleFinalStackView.addArrangedSubview(scheduleLabelStackView)
        scheduleFinalStackView.addArrangedSubview(scheduleImageView)
        
        scheduleImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        scheduleValueLabel.snp.makeConstraints { make in
            make.top.equalTo(scheduleLabel).offset(24)
        }
        
        finalStackView.addArrangedSubview(categoryFinalStackView)
        finalStackView.addArrangedSubview(scheduleFinalStackView)
        finalStackView.addSubview(separator)

        separator.snp.makeConstraints { make in
            make.centerY.equalTo(finalStackView)
            make.height.equalTo(1)
            make.leading.trailing.equalTo(finalStackView).inset(16)
        }
        
        scrollView.addSubview(emojiCollectionView)

        emojiCollectionView.snp.makeConstraints { make in
            make.top.equalTo(finalStackView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(18)
            make.height.equalTo(230)

        }
        scrollView.addSubview(colorCollectionView)
        
        colorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(emojiCollectionView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(18)
            make.height.equalTo(230)

        }
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(createButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(colorCollectionView.snp.bottom).offset(16)
            make.bottom.equalTo(scrollView.contentLayoutGuide).inset(34)
            make.leading.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.height.equalTo(60)
        }
        
        createButton.snp.makeConstraints { make in
            make.trailing.equalTo(scrollView).offset(-20)
            make.bottom.equalTo(scrollView.contentLayoutGuide).inset(34)
            make.top.equalTo(colorCollectionView.snp.bottom).offset(16)
            make.leading.equalTo(cancelButton.snp.trailing).offset(8)
            make.width.equalTo(cancelButton)
            make.height.equalTo(60)
        }
    }
    
    private func updateScheduleLabel(selectedDays: [Weekday]) {

        if selectedDays.isEmpty {
            scheduleValueLabel.text = nil
            scheduleValueLabel.isHidden = true
            scheduleLabelStackView.removeArrangedSubview(scheduleValueLabel)
            
        } else {
            let text = selectedDays
                .sorted { $0.rawValue < $1.rawValue }
                .map { $0.shortTitle }
                .joined(separator: ", ")
            scheduleValueLabel.text = text
            scheduleLabelStackView.insertArrangedSubview(scheduleValueLabel, at: 1)
            scheduleValueLabel.isHidden = false        }
    }
    
    private func updateCategoryLabel(selectedCategory: CategoryVM?) {
        categoryValueLabel.text = selectedCategory?.title
        categoryValueLabel.isHidden = (selectedCategory == nil)
    }
    
    @objc private func textFieldDidChange() {
        validateForm()
    }
    
    private func validateForm() {
        let hasTitle = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let hasCategory = addNewHabitViewModel.selectedCategory != nil
        let hasSchedule = !addNewHabitViewModel.selectedDays.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        let isValid = hasTitle && hasCategory && hasSchedule && hasEmoji && hasColor

        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .label : .systemGray
    }


    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let title = textField.text?.trimmingCharacters(in: .whitespaces),
              !title.isEmpty,
              let category = addNewHabitViewModel.selectedCategory,
              let emoji = selectedEmoji,
              let color = selectedColor else {
            return
        }

        let tracker = TrackerVM(
            id: Int.random(in: 1...100000),
            title: title,
            emoji: emoji,
            color: color
        )

        TrackerStore.shared.createTracker(tracker, categoryID: category.id)
        onTrackerCreated?()
        dismiss(animated: true)
    }
}

