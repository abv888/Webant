//
//  ViewController.swift
//  Webant
//
//  Created by Bagrat Arutyunov on 29.05.2021.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.unselectedItemTintColor = .gray
        self.tabBar.tintColor = .systemPink
    }
    
    
}

