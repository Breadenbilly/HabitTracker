//
//  Filters.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 20.3.2026.
//


import UIKit
import SnapKit

final class FiltersViewCell: UITableViewCell {

    static let reuseIdentifier = "FiltersTableViewCell"

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
        backgroundColor = .grayBackground.withAlphaComponent(0.3)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).inset(16)
            make.centerY.equalTo(contentView)
        }

        checkmarkImageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(contentView).inset(16)
        }
    }
}
