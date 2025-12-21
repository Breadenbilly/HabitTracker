//
//  CategoryTableViewCell.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 13.12.2025.
//

import UIKit
import SnapKit

final class CategoryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CategoryTableViewCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .grayBackground.withAlphaComponent(0.3)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, isSelected: Bool = false) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
    }
    
    func setupConstraints() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(checkmarkImageView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView).inset(16)
            make.height.equalTo(75)
            make.top.bottom.equalTo(contentView).inset(6)
          
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(containerView).inset(16)
            make.top.equalTo(containerView).offset(26)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalTo(containerView)
            make.trailing.equalTo(containerView).offset(-16)
        }
    }
}
