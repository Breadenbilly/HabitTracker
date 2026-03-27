//
//  AddNewHabitViewController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 31.10.2025.
//


import UIKit
import SnapKit

final class AddNewHabitViewController: UIViewController,
                                       UITextFieldDelegate,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout {

    var editingTracker: TrackerVM?

    private var didApplyInitialSelection = false

    private var errorLabelHeightConstraint: Constraint?
    private var daysCountLabelHeightConstraint: Constraint?
    private var daysCountLabelTopConstraint: Constraint?

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

    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
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

    private lazy var errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.textColor = .red
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        errorLabel.text = NSLocalizedString("Too many symbols", comment: "")
        return errorLabel
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
        textField.delegate = self
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

        if let tracker = editingTracker {
            title = NSLocalizedString("Edit habit", comment: "")
            createButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
            prefillForm(with: tracker)
            daysCountLabel.isHidden = false
            daysCountLabelHeightConstraint?.deactivate()
            let days = RecordStore.shared.completedDaysCount(for: tracker.id)
            daysCountLabel.text = String(format: NSLocalizedString("%d days", comment: ""), days)
        }
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

        scrollView.addSubview(daysCountLabel)
        daysCountLabel.snp.makeConstraints { make in
            daysCountLabelTopConstraint = make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(0).constraint
            make.centerX.equalTo(scrollView.contentLayoutGuide)
            daysCountLabelHeightConstraint = make.height.equalTo(0).constraint
        }
        scrollView.addSubview(textFieldView)
        textFieldView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(16)
            make.top.equalTo(daysCountLabel.snp.bottom).offset(24)
            make.height.equalTo(75)
        }

        textFieldView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(textFieldView).inset(16)
            make.centerY.equalTo(textFieldView)
        }

        scrollView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(textFieldView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(28)
            errorLabelHeightConstraint = make.height.equalTo(0).constraint
        }

        scrollView.addSubview(finalStackView)
        finalStackView.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(16)
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
            make.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
            make.bottom.equalTo(scrollView.contentLayoutGuide).inset(34)
            make.top.equalTo(colorCollectionView.snp.bottom).offset(16)
            make.leading.equalTo(cancelButton.snp.trailing).offset(8)
            make.width.equalTo(cancelButton)
            make.height.equalTo(60)
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if updatedText.count > 38 {
            setErrorVisible(true)
            return false
        } else {
            setErrorVisible(false)
            return true
        }
    }

    private func setErrorVisible(_ isVisible: Bool) {
        errorLabel.isHidden = !isVisible

        if isVisible {
            errorLabelHeightConstraint?.deactivate()   // пусть label сам возьмёт высоту
        } else {
            errorLabelHeightConstraint?.activate()     // высота 0
        }

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    private func updateScheduleLabel(selectedDays: [Weekday]) {
        if selectedDays.isEmpty {
            scheduleValueLabel.text = nil
            scheduleValueLabel.isHidden = true
            scheduleLabelStackView.removeArrangedSubview(scheduleValueLabel)
        } else {
            if selectedDays.count == Weekday.allCases.count {
                scheduleValueLabel.text = NSLocalizedString("Every day", comment: "")
            } else {
                let text = selectedDays
                    .sorted { $0.rawValue < $1.rawValue }
                    .map { $0.shortTitle }
                    .joined(separator: ", ")
                scheduleValueLabel.text = text
            }

            scheduleLabelStackView.insertArrangedSubview(scheduleValueLabel, at: 1)
            scheduleValueLabel.isHidden = false
        }

    }

    private func updateCategoryLabel(selectedCategory: CategoryVM?) {
        categoryValueLabel.text = selectedCategory?.title
        categoryValueLabel.isHidden = (selectedCategory == nil)
    }

    @objc private func textFieldDidChange() {
        if (textField.text ?? "").count <= 38 {
            setErrorVisible(false)
        }
        validateForm()
    }

    func validateForm() {
        let hasTitle = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let hasCategory = addNewHabitViewModel.selectedCategory != nil
        let hasSchedule = !addNewHabitViewModel.selectedDays.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        let isValid = hasTitle && hasCategory && hasSchedule && hasEmoji && hasColor

        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .label : .systemGray
    }

    private func prefillForm(with tracker: TrackerVM) {
        textField.text = tracker.title

        if let emojiIndex = emojis.firstIndex(of: tracker.emoji) {
            selectedEmoji = tracker.emoji
            selectedEmojiIndexPath = IndexPath(item: emojiIndex, section: 0)
        }

        if let colorIndex = colors.firstIndex(of: tracker.color) {
            selectedColor = tracker.color
            selectedColorIndexPath = IndexPath(item: colorIndex, section: 0)
        }

        addNewHabitViewModel.setSelectedDays(tracker.schedule)

        if let categoryID = tracker.categoryID,
           let category = CategoryStore.shared.fetchCategory(by: categoryID) {
            addNewHabitViewModel.setSelectedCategory(category)
        }

        validateForm()
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {
        guard let title = textField.text?.trimmingCharacters(in: .whitespaces),
              !title.isEmpty,
              let category = addNewHabitViewModel.selectedCategory,
              let emoji = selectedEmoji,
              let color = selectedColor else { return }

        let tracker = TrackerVM(
            id: editingTracker?.id ?? UUID(),  // сохраняем id при редактировании
            title: title,
            emoji: emoji,
            color: color,
            categoryID: category.id,
            schedule: addNewHabitViewModel.selectedDays
        )

        if editingTracker != nil {
            TrackerStore.shared.updateTracker(tracker, categoryID: category.id)
        } else {
            TrackerStore.shared.createTracker(tracker, categoryID: category.id)
        }

        onTrackerCreated?()
        dismiss(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didApplyInitialSelection, editingTracker != nil else { return }
        didApplyInitialSelection = true

        if let emojiIndexPath = selectedEmojiIndexPath {
            emojiCollectionView.selectItem(at: emojiIndexPath, animated: false, scrollPosition: [])
        }

        if let colorIndexPath = selectedColorIndexPath {
            colorCollectionView.selectItem(at: colorIndexPath, animated: false, scrollPosition: [])
        }
    }
}

