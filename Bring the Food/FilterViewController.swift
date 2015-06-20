//
//  FilterViewController.swift
//  Bring the Food
//
//  Created by federico badini on 16/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation
import UIKit

class FilterViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var freshFoodButton: UIButton!
    @IBOutlet weak var cookedFoodButton: UIButton!
    @IBOutlet weak var driedFoodButton: UIButton!
    @IBOutlet weak var frozenFoodButton: UIButton!
    @IBOutlet weak var expirationSlider: UISlider!
    @IBOutlet weak var maxExpirationLabel: UILabel!
    
    // Delegate
    var delegate: FilterProtocol? = nil
    
    // Variables populated from prepareForSegue
    var filterState: FilterState?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func freshFoodButtonPressed(sender: UIButton) {
        if(filterState!.isFreshFood){
            freshFoodButton.selected = false
            filterState!.isFreshFood = false
        }
        else{
            freshFoodButton.selected = true
            filterState!.isFreshFood = true
        }
    }
    
    @IBAction func cookedFoodButtonPressed(sender: UIButton) {
        if(filterState!.isCookedFood){
            cookedFoodButton.selected = false
            filterState!.isCookedFood = false
        }
        else{
            cookedFoodButton.selected = true
            filterState!.isCookedFood = true
        }
    }
    
    @IBAction func driedFoodButtonPressed(sender: UIButton) {
        if(filterState!.isDriedFood){
            driedFoodButton.selected = false
            filterState!.isDriedFood = false
        }
        else{
            driedFoodButton.selected = true
            filterState!.isDriedFood = true
        }
    }
    
    @IBAction func frozenFoodButtonPressed(sender: UIButton) {
        if(filterState!.isFrozenFood){
            frozenFoodButton.selected = false
            filterState!.isFrozenFood = false
        }
        else{
            frozenFoodButton.selected = true
            filterState!.isFrozenFood = true
        }
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        if(sender.value == 60){
            maxExpirationLabel.text = "60+"
        }
        else{
            maxExpirationLabel.text = String(stringInterpolationSegment: Int(sender.value))
        }
    }
    
    @IBAction func applyFilterButtonPressed(sender: AnyObject) {
        filterState?.expiration = Int(expirationSlider.value)
        self.delegate?.handleFiltering(filterState!)
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // User interface settings
    private func setUpInterface(){
        freshFoodButton.setImage(UIImage(named: "fresh"), forState: UIControlState.Selected)
        freshFoodButton.highlighted = false
        cookedFoodButton.setImage(UIImage(named: "cooked"), forState: UIControlState.Selected)
        cookedFoodButton.highlighted = false
        driedFoodButton.setImage(UIImage(named: "dried"), forState: UIControlState.Selected)
        driedFoodButton.highlighted = false
        frozenFoodButton.setImage(UIImage(named: "frozen"), forState: UIControlState.Selected)
        frozenFoodButton.highlighted = false
        if(filterState!.isFreshFood){
            freshFoodButton.selected = true
        }
        else{
            freshFoodButton.selected = false
        }
        if(filterState!.isCookedFood){
            cookedFoodButton.selected = true
        }
        else{
            cookedFoodButton.selected = false
        }
        if(filterState!.isDriedFood){
            driedFoodButton.selected = true
        }
        else{
            driedFoodButton.selected = false
        }
        if(filterState!.isFrozenFood){
            frozenFoodButton.selected = true
        }
        else{
            frozenFoodButton.selected = false
        }
        expirationSlider.setThumbImage(UIImage(named: "slider"), forState: .Normal)
        expirationSlider.setValue(Float(filterState!.expiration), animated: false)
        sliderValueChanged(expirationSlider)
    }
}
