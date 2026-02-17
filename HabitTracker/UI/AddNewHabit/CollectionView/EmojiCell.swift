//
//  EmojiCell.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 5.2.2026.
//

import UIKit
import SnapKit

final class EmojiCell: UICollectionViewCell {

    static let reuseIdentifier = "EmojiCell"

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 34)
        return label
    }()

    private let selectedView: UIView = {
        let selectedView = UIView()
        selectedView.backgroundColor = .systemGray5
        selectedView.layer.cornerRadius = 16
        selectedView.isHidden = true
        return selectedView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(selectedView)
        contentView.addSubview(label)
        selectedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(with emoji: String) {
        label.text = emoji
    }

    func configure(isSelected: Bool) {
        selectedView.isHidden = !isSelected
    }
}
