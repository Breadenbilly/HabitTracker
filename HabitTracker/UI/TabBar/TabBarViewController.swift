//
//  TabBarViewController.swift
//  HabitTracker
//
//  Created by Timur Mamedov on 31.10.2025.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        if !hasSeenOnboarding {
            let onboardingContainer = OnboardingContainer()
            onboardingContainer.modalPresentationStyle = .fullScreen
            present(onboardingContainer, animated: true)
        }
    }

    private func setupView() {
        
        let trackerViewController = TrackerViewController()
        let statisticsViewController = StatisticsViewController()
        
        let trackerNavigationContoller = UINavigationController(rootViewController: trackerViewController)
        let statisticsNavigationContoller = UINavigationController(rootViewController: statisticsViewController)
        
        trackerNavigationContoller.tabBarItem = UITabBarItem(
            title: "Tracker",
            image: UIImage(systemName: "record.circle.fill"),
            tag: 0
        )
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Statistics",
            image: UIImage(systemName: "hare.fill"),
            tag: 1
        )

        
        viewControllers = [trackerNavigationContoller, statisticsNavigationContoller]
        
    
    }
}
