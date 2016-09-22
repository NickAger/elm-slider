//
//  ViewController.swift
//  ServerSlider
//
//  Created by Nick Ager on 21/09/2016.
//  Copyright © 2016 Rocketbox Ltd. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var sliderNumberLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func sliderChanged(_ sender: NSSlider) {
        sliderNumberLabel.stringValue = "("  + sender.stringValue + ")"
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

