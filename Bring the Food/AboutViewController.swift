//
//  AboutViewController.swift
//  Bring the Food
//
//  Created by federico badini on 23/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backWithSwipe(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}