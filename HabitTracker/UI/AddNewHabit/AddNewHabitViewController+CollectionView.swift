//
//  AddNewHabitViewController+CollectionView.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 12.2.2026.
//

import UIKit

extension AddNewHabitViewController {
    // размер хедера (либо 28 для цвета или эмодзи либо никакой)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard collectionView === emojiCollectionView || collectionView === colorCollectionView else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 28)
    }
    // создает элемент для коллеции  либо хедер либо футер. сначала выбираем что создаем. потом для какой коллекции какой хедер. Возвращаем пустой реюзабл вью если не проходит ни одну из идентификаций
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "CollectionViewHeader",
            for: indexPath
        ) as! CollectionViewHeader

        let title: String
        if collectionView === emojiCollectionView {
            title = "Emoji"
        } else {
            title = NSLocalizedString("Color", comment: "")
        }

        header.configure(title: title)
        return header
    }
// отступ для коллеции. в нашем случае един для всего
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 10, bottom: 0, right: 10)
    }
// размер каждой ячейки
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 52, height: 52)
    }
// количество ячеек в коллекциях. Можно улучшить. как?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === emojiCollectionView {
            return emojis.count
        } else if collectionView === colorCollectionView {
            return colors.count
        } else {fatalError("Unexpected collectionView") }
    }
// выбор ячейки из созданной
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseIdentifier,
                for: indexPath
            ) as! EmojiCell
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji)
            return cell
        } else if collectionView === colorCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.reuseIdentifier,
                for: indexPath
            ) as! ColorCell
            let color = colors[indexPath.item]

            cell.configure(with: color)
            return cell
        }
        else { fatalError("Unexpected collectionView")}
    }

// активация выбора при тапе
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollectionView {
            if let prev = selectedEmojiIndexPath, prev != indexPath {
                let prevCellAsEmoji = collectionView.cellForItem(at: prev) as? EmojiCell
                prevCellAsEmoji?.configure(isSelected: false)

            }
            let cellAsEmoji = collectionView.cellForItem(at: indexPath) as? EmojiCell
            cellAsEmoji?.configure(isSelected: true)

            selectedEmojiIndexPath = indexPath
            selectedEmoji = emojis[indexPath.item]
        } else if collectionView === colorCollectionView {
            if let prevColor = selectedColorIndexPath, prevColor != indexPath {
                let prevCellAsColor = collectionView.cellForItem(at: prevColor) as? ColorCell
                prevCellAsColor?.configure(isSelected: false)

            }
            let cellAsColor = collectionView.cellForItem(at: indexPath) as? ColorCell
            cellAsColor?.configure(isSelected: true)

            selectedColorIndexPath = indexPath
            selectedColor = colors[indexPath.item]
         } else {
            fatalError("Unexpected collectionView")
        }
    }
}

