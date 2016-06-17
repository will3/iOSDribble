//
//  ViewController.swift
//  RadarChart
//
//  Created by will3 on 17/06/16.
//  Copyright © 2016 will3. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var radarChart: RadarChart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        radarChart?.data = RadarChart.Data()
        radarChart?.data.axis = ["STRENGTH", "AGILITY", "INTELLIGENCE", "CHARISMA", "STAMINA"]
        radarChart?.data.sets = [
            [7.0, 5.0, 9.0, 8.5, 7.2],
            [6.2, 7.2, 3.4, 7.2, 6.2]
        ]
        
        radarChart?.data.colors = [
            UIColor(red: 96 / 256.0, green: 88 / 256.0, blue: 148 / 256.0, alpha: 0.6),
            UIColor(red: 222 / 256.0, green: 82 / 256.0, blue: 125 / 256.0, alpha: 0.6)
        ]
        
        radarChart?.setNeedsDisplay()
        
        self.view.backgroundColor = UIColor(red: 53 / 256.0, green: 50 / 256.0, blue: 80 / 256.0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onButtonPressed(sender: AnyObject) {
        radarChart?.data.sets = [
            [random(), random(), random(), random(), random(), random()],
            [random(), random(), random(), random(), random(), random()],
            [random(), random(), random(), random(), random(), random()]
        ]
        radarChart?.data.axis = ["STRENGTH", "AGILITY", "INTELLIGENCE", "CHARISMA", "STAMINA", "LUCK"]
        
        radarChart?.data.colors = [
            UIColor(red: 96 / 256.0, green: 88 / 256.0, blue: 148 / 256.0, alpha: 0.6),
            UIColor(red: 222 / 256.0, green: 82 / 256.0, blue: 125 / 256.0, alpha: 0.6),
            UIColor(red: 180 / 256.0, green: 140 / 256.0, blue: 60 / 256.0, alpha: 0.6)
        ]
        
        radarChart?.setNeedsDisplay()
    }
    
    private func random() -> Double {
        return pow(Double(arc4random()) / Double(UINT32_MAX), 0.5) * 10.0
    }
}

