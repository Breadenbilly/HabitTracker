import UIKit
import SnapKit

final class ScheduleSelectionViewController: UIViewController {
    
    var preselectedDays: [Weekday] = []
    
    var onDone: (([Weekday]) -> Void)?
    
    private let presenter = ScheduleSelectionViewPresenter()
    
    private let days = [
        NSLocalizedString("Monday", comment: ""),
        NSLocalizedString("Tuesday", comment: ""),
        NSLocalizedString("Wednesday", comment: ""),
        NSLocalizedString("Thursday", comment: ""),
        NSLocalizedString("Friday", comment: ""),
        NSLocalizedString("Saturday", comment: ""),
        NSLocalizedString("Sunday", comment: "")
    ]
    
    private var selectedDays: [Bool] = Array(repeating: false, count: 7)
    private var switches: [UISwitch] = []
    
    // Контейнер
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayBackground.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let finalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
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
        presenter.viewController = self
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("Schedule", comment: "")
        
        for day in preselectedDays {
                   selectedDays[day.rawValue] = true
               }
        
        setupLayout()
        setupRows()
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        view.addSubview(cardView)
        cardView.addSubview(finalStackView)
        view.addSubview(doneButton)
        
        cardView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(525)
        }
        
        finalStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        doneButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view).inset(50)
            make.height.equalTo(60)
        }
    }
    
    // MARK: - Rows
    
    private func setupRows() {
        switches.removeAll()
        
        for (index, title) in days.enumerated() {
            let row = makeRow(for: index, title: title, isLast: index == days.count - 1)
            finalStackView.addArrangedSubview(row)
        }
    }
    
    private func makeRow(for index: Int, title: String, isLast: Bool) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.text = title
        
        let sw = UISwitch()
        sw.onTintColor = .systemBlue
        sw.tag = index
        sw.isOn = selectedDays[index]
        sw.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        switches.append(sw)
        
        container.addSubview(label)
        container.addSubview(sw)
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        sw.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        container.snp.makeConstraints { make in
            make.height.equalTo(75)
        }
        
        if !isLast {
            let separator = UIView()
            separator.backgroundColor = UIColor.separator.withAlphaComponent(0.4)
            container.addSubview(separator)
            
            separator.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func doneTapped() {
        
        let result: [Weekday] = selectedDays.enumerated().compactMap { index, isOn in
                   guard isOn else { return nil }
                   return Weekday(rawValue: index)
               }
               
               onDone?(result)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        selectedDays[index] = sender.isOn
    }
}
