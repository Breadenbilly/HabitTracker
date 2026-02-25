//
//  OnboardingContainer.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 19.2.2026.
//

import UIKit
import SnapKit

final class OnboardingContainer: UIPageViewController, UIPageViewControllerDataSource {
    
    private lazy var pages: [UIViewController] = [
        OnboardingViewController(title: "Отслеживайте только то, что хотите", imageName: "OnboardingBlue"),
        OnboardingViewController(title: "Даже если это не литры воды и йога", imageName: "OnboardingRed")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([pages[0]], direction: .forward, animated: false)
    }
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else {
        return nil
        }

        let previousIndex = index - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = index + 1
        guard nextIndex < pages.count else {
            return nil
        }
        return pages[nextIndex]
    }
}
