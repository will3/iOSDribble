//
//  MultipleInput.swift
//  MultipleInput
//
//  Created by will3 on 17/06/16.
//  Copyright © 2016 will3. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

// Inspired by http://www.ios.uplabs.com/posts/1-input-4-all

class ColorUtils {
    static func getColor(r r: Int, g: Int, b: Int) -> UIColor {
        return UIColor(red: CGFloat(r) / 256.0, green: CGFloat(g) / 256.0, blue: CGFloat(b) / 256.0, alpha: 1.0)
    }
}

struct Images {
    var rightArrow = UIImage(named: "arrow")
    var tick = UIImage(named: "tick")
}

struct Colors {
    var primary = ColorUtils.getColor(r: 0, g: 99, b: 223)
    var primaryDim = ColorUtils.getColor(r: 3, g: 75, b: 175)
    var primaryLight = ColorUtils.getColor(r: 0, g: 108, b: 251)
    var secondary = ColorUtils.getColor(r: 91, g: 182, b: 100)
    var text = ColorUtils.getColor(r: 12, g: 30, b: 63)
    var shadow = UIColor.blackColor()
}

struct Strings {
    var doneMessage = NSLocalizedString("Let's go!", comment: "")
}

protocol MultipleInputDelegate: class {
    func multipleInput(multipleInput: MultipleInput, didShowPlaceHolderAtIndex index: Int)
    func multipleInput(multipleInput: MultipleInput, shouldShowPlaceHolderAtIndex index: Int) -> Bool
    func didPressButtonWithMultipleInput(multipleInput: MultipleInput)
}

class MultipleInput: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var placeholderLabel: UILabel?
    @IBOutlet weak var inputContainer: UIView?
    @IBOutlet weak var progressBackgroundView: UIView?
    @IBOutlet weak var progressLabel: UILabel?
    
    weak var delegate: MultipleInputDelegate?
    
    var colors = Colors()
    var images = Images()
    var strings = Strings()
    
    var textField: UITextField?
    var rightButton: UIButton?
    var progressView: UIView?
    var doneView = UIView()
    var doneViewTickImage: UIView?
    var doneViewLabel: UIView?
    var button: UIButton?
    private var doneViewIntitialized = false
    
    var placeHolders = [String]()
    var index = 0
    var textFieldLeftPadding = CGFloat(8.0)
    var progressViewHeight = CGFloat(2.0)
    
    var texts = [Int: String]()
    
    static func newInstance(placeHolders: [String]) -> MultipleInput {
        let input = NSBundle.mainBundle().loadNibNamed("MultipleInput", owner: nil, options: nil)[0] as! MultipleInput
        input.placeHolders = placeHolders
        input.updateView(animated: false)
        return input
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    var progressViewAnimateDuration = 0.2
    
    func updateView(animated animated: Bool = false) {
        let isDone = index == placeHolders.count
        
        self.placeholderLabel?.alpha = isDone ? 0.0: 1.0
        self.placeholderLabel?.text = index < placeHolders.count ? placeHolders[index] : " "
        self.progressLabel?.alpha = isDone ? 0.0: 1.0
        self.progressLabel?.text = String.init(format: NSLocalizedString("%d/%d", comment: ""),
                                               index,
                                               placeHolders.count)
        
        if !isDone {
            doneViewTickImage?.alpha = 0.0
            doneViewLabel?.alpha = 0.0
        }
        
        inputContainer?.backgroundColor = colors.primary
        progressBackgroundView?.backgroundColor = colors.primaryDim
        self.backgroundColor = colors.primaryLight
        placeholderLabel?.textColor = colors.text
        progressLabel?.textColor = colors.text
        doneView.backgroundColor = colors.secondary
        
        guard let inputContainer = self.inputContainer else { return }
        
        if textField == nil {
            // Set up textField and right button
            textField = UITextField()
            textField?.tintColor = colors.primaryDim
            textField?.textColor = colors.text
            inputContainer.addSubview(textField!)
            rightButton = UIButton()
            rightButton?.setImage(images.rightArrow, forState: UIControlState.Normal)
            inputContainer.addSubview(rightButton!)
            textField?.snp_makeConstraints { make in
                make.left.equalTo(inputContainer).offset(textFieldLeftPadding)
                make.top.equalTo(inputContainer)
                make.bottom.equalTo(inputContainer)
            }
            
            textField?.delegate = self
            
            rightButton?.snp_makeConstraints { make in
                make.size.equalTo(CGSizeMake(42.0, 42.0))
                make.right.equalTo(inputContainer)
                make.left.equalTo(textField!.snp_right)
                make.centerY.equalTo(textField!.snp_centerY)
            }
            
            rightButton?.addTarget(self, action: #selector(MultipleInput.onRightPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if progressView == nil {
            progressView = UIView()
            progressView?.backgroundColor = colors.secondary
            inputContainer.addSubview(progressView!)
        }
        
        let width = self.bounds.width * CGFloat(index) / CGFloat(placeHolders.count)
        progressView?.snp_updateConstraints { make in
            make.left.equalTo(0.0)
            make.bottom.equalTo(0.0)
            make.width.equalTo(width)
            make.height.equalTo(progressViewHeight)
        }
        
        if (animated) {
            UIView.animateWithDuration(progressViewAnimateDuration) {
                inputContainer.layoutIfNeeded()
            }
        }
    }
    
    func onRightPressed(sender: AnyObject) {
        next()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        next()
        return true
    }
    
    func next() {
        if index < placeHolders.count {
            let shouldShow = delegate == nil ? true :
                delegate!.multipleInput(self, shouldShowPlaceHolderAtIndex: index)
            if !shouldShow {
                return
            }
            
            textField?.text = ""
            texts[index] = textField?.text ?? ""
            
            index += 1
            updateView(animated: true)
            
            if index == placeHolders.count {
                done()
            } else {
                delegate?.multipleInput(self, didShowPlaceHolderAtIndex: index)
            }
        }
    }
    
    func done() {
        guard let inputContainer = self.inputContainer else { return }
        
        let bounds = inputContainer.bounds
        
        if !doneViewIntitialized {
            inputContainer.addSubview(doneView)
            let doneViewTickImage = UIImageView(image: images.tick)
            doneView.addSubview(doneViewTickImage)
            doneViewTickImage.snp_makeConstraints { make in
                make.center.equalTo(inputContainer)
                make.size.equalTo(CGSizeMake(42.0, 42.0))
            }
            doneViewTickImage.layer.magnificationFilter = kCAFilterNearest
            doneViewTickImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4)
            doneViewTickImage.alpha = 0.0
            
            let doneViewLabel = UILabel()
            doneViewLabel.text = strings.doneMessage
            doneView.addSubview(doneViewLabel)
            doneViewLabel.snp_makeConstraints { make in
                make.center.equalTo(inputContainer)
            }
            doneViewLabel.textColor = colors.text
            doneViewLabel.alpha = 0.0
            doneViewLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4)
            
            self.doneViewTickImage = doneViewTickImage
            self.doneViewLabel = doneViewLabel
            
            doneViewIntitialized = true
        }
        
        doneView.frame = CGRect(x: 0, y: bounds.height - progressViewHeight, width: bounds.width, height: progressViewHeight)
        
        UIView.animateWithDuration(0.3, delay: progressViewAnimateDuration, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.doneView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        }) { v in
                    let doneViewLabel = self.doneViewLabel!
            let doneViewTickImage = self.doneViewTickImage!
            
            let durations = [0.1, 0.1, 0.05, 0.05]
            let totalDuration = durations.reduce(0) { $0 + $1 }
            AnimationUtils.animate(view: doneViewTickImage, scales: [1.2, 0.9, 1.05, 1.00], withDurations: durations) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    doneViewTickImage.alpha = 0.0
                    
                    AnimationUtils.animate(view: doneViewLabel, scales: [1.2, 0.9, 1.05, 1.00], withDurations: durations) {
                        
                    }
                    
                    UIView.animateWithDuration(totalDuration, animations: {
                        doneViewLabel.alpha = 1.0
                        inputContainer.layer.shadowColor = self.colors.shadow.CGColor
                        inputContainer.layer.shadowOpacity = 0.5
                        inputContainer.layer.shadowOffset = CGSizeMake(0, 5)
                    }) { done in
                        if (self.button == nil) {
                            self.button = UIButton()
                            inputContainer.addSubview(self.button!)
                            self.button?.snp_makeConstraints { make in
                                make.edges.equalTo(inputContainer)
                            }
                            self.button?.addTarget(self, action: #selector(MultipleInput.onButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                        }
                    }
                });
            }
            
            UIView.animateWithDuration(totalDuration) {
                doneViewTickImage.alpha = 1.0
            }
        }
        
        UIView.animateWithDuration(0.2, delay: progressViewAnimateDuration, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.progressLabel?.alpha = 0.0
            self.placeholderLabel?.alpha = 0.0
        }) { v in }
    }
    
    func onButtonPressed(sender: AnyObject) {
        delegate?.didPressButtonWithMultipleInput(self)
    }
    
    func reset() {
        guard let inputContainer = self.inputContainer else { return }
 
        inputContainer.layer.shadowOpacity = 0.0
        
        self.button?.removeFromSuperview()
        self.button = nil
        
        UIView.animateWithDuration(0.2) {
            self.doneView.frame = CGRectMake(0, 0, inputContainer.bounds.width, 0)
        }
        
        index = 0
        updateView()
    }
}

class AnimationUtils {
    static func animate(view view: UIView, scales: [CGFloat], withDurations durations: [NSTimeInterval], index: Int = 0,  completion: () -> Void) {
        UIView.animateWithDuration(durations[index], animations: {
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, scales[index], scales[index])
        }) { done in
            if index + 1 < scales.count {
                animate(view: view, scales: scales, withDurations: durations, index: index + 1, completion: completion)
            } else {
                completion()
            }
        }
    }
}