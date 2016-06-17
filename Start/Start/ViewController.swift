//
//  ViewController.swift
//  Start
//
//  Created by will3 on 17/06/16.
//  Copyright © 2016 will3. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var launchIcon: LaunchIcon?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.blackColor()
        
        launchIcon?.performSelector(#selector(LaunchIcon.startAnimating), withObject: nil, afterDelay: 10.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

