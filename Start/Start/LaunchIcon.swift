//
//  LaunchIcon.swift
//  Start
//
//  Created by will3 on 17/06/16.
//  Copyright © 2016 will3. All rights reserved.
//

import Foundation
import UIKit

// http://www.ios.uplabs.com/posts/start-launch-screen

class LaunchIcon: UIView {
    var data =
    " *****" + "\n" +
    "******" + "\n" +
    "**"     + "\n" +
    "***** " + "\n" +
    " *****" + "\n" +
    "    **" + "\n" +
    "******" + "\n" +
    "*****"
    
    class Dot {
        var i = 0
        var j = 0
        var life = 1.0
        var dying = false
        var alpha = 1.0
        var scale = 1.0
    }
    
    var dots = [Dot]()
    // List of indexes in |dots that are alive
    var aliveDots = [Int]()
    
    // Grid size
    var gridSize = CGFloat(20.0)
    
    // Default circle size
    var circleSize = CGFloat(14.0)
    
    // Color of circles
    let color = UIColor(red: 111 / 256.0, green: 227 / 256.0, blue: 252 / 256.0, alpha: 1.0)
    
    // Frame rate
    var frameRate = 24.0
    
    // Set this to get a call back when all animations finish
    var completion: (() -> Void)?
    
    // Setting this to a higher value makes dots 'die faster
    var dyingSpeed = 0.1
    
    // Which point during animation dot is biggest
    var dotAnimatePeak = 0.8
    
    // How much to scale up at initial frames of animation
    var dotAnimateScaleUp = 0.3
    
    private var columns = 0
    private var rows = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        updateDots()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextClearRect(context, rect)
        
        let center = CGPointMake(rect.width / 2, rect.height / 2)
        let halfColumns = CGFloat(columns) * CGFloat(0.5)
        let halfRows = CGFloat(rows) * CGFloat(0.5)
        
        for dot in dots {
            let color2 = color.colorWithAlphaComponent(CGFloat(dot.alpha))
            CGContextSetFillColorWithColor(context, color2.CGColor)
            let circleSize2 = circleSize * CGFloat(dot.scale)
            
            CGContextAddEllipseInRect(context, CGRectMake(
                center.x + gridSize * (CGFloat(dot.j) - halfColumns + 0.5) - circleSize2 / 2.0,
                center.y + gridSize * (CGFloat(dot.i) - halfRows + 0.5) - circleSize2 / 2.0,
                circleSize2, circleSize2))
            CGContextFillPath(context)
        }
    }
    
    func updateDots() {
        dots.removeAll()
        aliveDots.removeAll()
        var lines = data.componentsSeparatedByString("\n")
        
        var maxColumns = -1
        for i in 0...lines.count - 1 {
            let line = lines[i]
            if line.characters.count == 0 {
                continue
            }
            for j in 0...line.characters.count - 1 {
                if line.characters.count > maxColumns {
                    maxColumns = line.characters.count
                }
                
                let r = Range<String.Index>(line.startIndex.advancedBy(j) ..< line.startIndex.advancedBy(j + 1))
                if line[r] == " " {
                    continue
                }
                
                let dot = Dot()
                dot.i = i
                dot.j = j
                dots.append(dot)
                
                aliveDots.append(dots.count - 1)
            }
        }
        
        rows = lines.count
        columns = maxColumns
    }
    
    var timer: NSTimer?
    
    func startAnimating() {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0 / frameRate, target: self, selector: #selector(LaunchIcon.tick), userInfo: nil, repeats: true)
    }
    
    func stopAnimating() {
        timer?.invalidate()
    }
    
    func tick() {
        var completed = true
        
        dots.forEach { dot in
            if dot.dying {
                dot.life -= dyingSpeed
            }
            if dot.life > 0 {
                completed = false
            }
            
            dot.alpha = dot.life
            
            if dot.life > dotAnimatePeak {
                dot.scale = 1 + (1 - dot.life) / (1 - dotAnimatePeak) * dotAnimateScaleUp
            } else {
                dot.scale = dot.life / dotAnimatePeak
            }
        }
        
        if completed {
            completion?()
            timer?.invalidate()
        }
        
        setNeedsDisplay()
        
        if aliveDots.count == 0 {
            return
        }
        
        let index = Int(arc4random()) % aliveDots.count
        let dotsIndex = aliveDots[index]
        
        let dot = dots[dotsIndex]
        if dot.dying {
            fatalError("oh no")
        }
        dot.dying = true
        
        aliveDots.removeAtIndex(index)
    }
    
}