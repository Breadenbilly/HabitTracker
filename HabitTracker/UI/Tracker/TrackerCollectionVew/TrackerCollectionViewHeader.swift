//
//  TrackerCollectionViewHeader.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 9.12.2025.
//

import UIKit
import SnapKit

final class TrackerCollectionViewHeader: UICollectionReusableView {
    
    static let reuseIdentifier: String = "TrackerCollectionViewHeader"
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textAlignment = .left
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        headerLabel.text = title
    }
}
