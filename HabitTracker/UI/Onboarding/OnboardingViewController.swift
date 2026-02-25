//
//  OnboardingViewController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 18.2.2026.
//
import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {

    private let labelText: String
    private let imageName: String

    private let backgroundImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 8
        return button
    }()

    init(title: String, imageName: String) {
        self.labelText = title
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        label.text = labelText
        backgroundImageView.image = UIImage(named: imageName)
        setupConstraints()
    }

    private func setupConstraints() {
        view.addSubview(backgroundImageView)
        view.addSubview(label)
        view.addSubview(button)

        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        button.snp.makeConstraints { (make) in
            make.height.equalTo(60)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(80)
        }
    }
}
