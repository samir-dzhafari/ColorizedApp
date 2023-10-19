//
//  ViewController.swift
//  ColorizedApp
//
//  Created by Самир Джафари on 18.10.2023.
//

import UIKit

final class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settingsVC = segue.destination as? SettingsViewController else {
            return
        }
        
        settingsVC.deligate = self
        settingsVC.color = view.backgroundColor
    }
    
}

// MARK: - SettingsViewControllerDelegate

extension MainViewController: SettingsViewControllerDelegate {
    func doneButtonPressed(_ color: UIColor) {
        view.backgroundColor = color
    }
    
    
}

