//
//  ViewController.swift
//  MultipleInput
//
//  Created by will3 on 17/06/16.
//  Copyright © 2016 will3. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, MultipleInputDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let multipleInput = MultipleInput.newInstance(["Full Name", "Email", "Password"])
        multipleInput.delegate = self
        
        self.view.addSubview(multipleInput)
        multipleInput.snp_makeConstraints { (make) in
            make.left.equalTo(self.view).offset(20.0)
            make.right.equalTo(self.view).offset(-20.0)
            make.center.equalTo(self.view)
        }
        
        self.view.backgroundColor = multipleInput.colors.primaryLight
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: MultipleInputDelegate
    
    func multipleInput(multipleInput: MultipleInput, didShowPlaceHolderAtIndex index: Int) {
        multipleInput.textField?.secureTextEntry = index == 2
    }
    
    func multipleInput(multipleInput: MultipleInput, shouldShowPlaceHolderAtIndex index: Int) -> Bool {
        return true
    }
    
    func didPressButtonWithMultipleInput(multipleInput: MultipleInput) {
        multipleInput.reset()
    }
}

