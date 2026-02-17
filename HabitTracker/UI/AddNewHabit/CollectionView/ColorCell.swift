//
//  ColorCell.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 9.2.2026.
//

import UIKit
import SnapKit

final class ColorCell: UICollectionViewCell {

    static let reuseIdentifier = "ColorCell"

    private let colorView: UIView = {
        let colorLabel = UIView()
        colorLabel.layer.cornerRadius = 8
        colorLabel.layer.borderColor = UIColor.white.cgColor
        colorLabel.layer.borderWidth = 3
        return colorLabel
    }()

    private let selectedView: UIView = {
        let selectedView = UIView()
        selectedView.layer.cornerRadius = 8
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
        contentView.addSubview(colorView)
        selectedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        colorView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(3)
        }
    }

    func configure(with color: String) {
        colorView.backgroundColor = UIColor(hex: color)
        selectedView.backgroundColor = UIColor(hex: color)?.withAlphaComponent(0.3)
    }

    func configure(isSelected: Bool) {
        selectedView.isHidden = !isSelected
    }
}

extension UIColor {
    convenience init?(hex: String) {

        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")

        guard hexFormatted.count == 6,
              let rgb = Int(hexFormatted, radix: 16) else { return nil }

        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
