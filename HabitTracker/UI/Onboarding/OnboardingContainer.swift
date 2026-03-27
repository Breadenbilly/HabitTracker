//
//  OnboardingContainer.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 19.2.2026.
//

import UIKit
import SnapKit

final class OnboardingContainer: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private var pageControl = UIPageControl()

    private lazy var pages: [UIViewController] = [
        OnboardingViewController(title: NSLocalizedString("Track only what you want", comment: ""), imageName: "OnboardingBlue"),
        OnboardingViewController(title: NSLocalizedString("Even if its not yoga", comment: ""), imageName: "OnboardingRed")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        setViewControllers([pages[0]], direction: .forward, animated: false)
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .black
        setupConstraints()
    }
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraints() {
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-120)
            make.centerX.equalToSuperview()
        }
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
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            completed,
            let currentViewController = pageViewController.viewControllers?.first,
            let currentIndex = pages.firstIndex(of: currentViewController)
        else {
            return
        }
        pageControl.currentPage = currentIndex
    }
}
