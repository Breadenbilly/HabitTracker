//
//  TrackerCollectionViewCell.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 8.12.2025.
//
import SnapKit
import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "TrackerCollectionViewCell"
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .systemGreen
        containerView.layer.cornerRadius = 16
        return containerView
    }()
    
    private let emojiBackgroundLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.text = "🗯"
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.text = ""
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.text = "0"
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        let configure = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setImage(UIImage(systemName: "plus", withConfiguration: configure), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
            super.init(frame: frame)
        setupConstraints()
        }
        
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
   private func setupConstraints() {
        contentView.addSubview(containerView)
        containerView.addSubview(emojiBackgroundLabel)
        emojiBackgroundLabel.addSubview(emojiLabel)
        containerView.addSubview(titleLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(plusButton)
        
       containerView.snp.makeConstraints { make in
                   make.top.leading.trailing.equalToSuperview()
                   make.height.equalTo(90)
               }
        
        emojiBackgroundLabel.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.leading.top.equalTo(containerView).inset(12)
        }
        
        emojiLabel.snp.makeConstraints { make in
            make.center.equalTo(emojiBackgroundLabel)
            make.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(containerView).inset(12)
        }
        
        daysLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(18)
            make.left.equalTo(containerView).offset(12)
        }

        plusButton.snp.makeConstraints { make in
            make.height.width.equalTo(34)
            make.top.equalTo(containerView.snp.bottom).offset(8)
            make.trailing.equalTo(containerView.snp.trailing).offset(-12)
        }
        
    }
    
    func configure(emoji: String, title: String, days: Int, color: UIColor) {
           emojiLabel.text = emoji
           titleLabel.text = title
           daysLabel.text = "\(days) дней"
           containerView.backgroundColor = color
        plusButton.backgroundColor = color
       }
        
    }

