//
//  RadarChart.swift
//  RadarChart
//
//  Created by will3 on 17/06/16.
//  Copyright © 2016 will3. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

// Inspiration: http://www.ios.uplabs.com/posts/grandaddy-purple-strain

class RadarChart: UIView {

    class Data {
        var axis = [String]()
        var sets = [[Double]]()
        var max = 10.0
        var minUnit = 2.5
        var colors = [UIColor]()
    }
    
    class Layer: UIView {
        var data = Data()
        var index = 0
        var graphHalfWidth = CGFloat(110.0)
        var color = UIColor(red: (CGFloat(arc4random()) % 256) / 256.0,
                            green: (CGFloat(arc4random()) % 256) / 256.0,
                            blue: (CGFloat(arc4random()) % 256) / 256.0,
                            alpha: 0.5)
        
        override func drawRect(rect: CGRect) {
            let context = UIGraphicsGetCurrentContext()
            CGContextClearRect(context, rect)
            
            let center = CGPointMake(bounds.width / 2, bounds.height / 2)

            let axisCount = data.axis.count
            
            let path = CGPathCreateMutable();
            
            CGContextSetFillColorWithColor(context, color.CGColor)
            
            for i in 0...data.axis.count - 1 {
                let angle = M_PI * 2.0 / Double(axisCount) * Double(i)
                let ratio = data.sets[index][i] / data.max
                let x = center.x + CGFloat(cos(angle) * Double(graphHalfWidth) * ratio)
                let y = center.y + CGFloat(sin(angle) * Double(graphHalfWidth) * ratio)
                
                if i == 0 {
                    CGPathMoveToPoint(path, nil, x, y)
                } else {
                    CGPathAddLineToPoint(path, nil, x, y)
                }
            }
            
            self.layer.shadowPath = path
            self.layer.shadowOpacity = 0.5
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowRadius = 5.0
            self.layer.shadowOffset = CGSizeMake(0, 0)
            
            CGContextAddPath(context, path)
            CGContextFillPath(context)
            
            UIGraphicsEndImageContext()
        }
    }
    
    var data = Data()
    
    var layers = [Int: Layer]()
    
    var graphHalfWidth = CGFloat(110.0)
    
    var font = UIFont.systemFontOfSize(14.0)
    
    var labelGap = 2.0
    
    var axisLabelColor = UIColor.whiteColor()
    var gridLineColor = UIColor(white: 1.0, alpha: 0.2)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        
        let center = CGPointMake(bounds.width / 2, bounds.height / 2)
        
        if let context = UIGraphicsGetCurrentContext() {
            
            CGContextClearRect(context, rect)
            
            // Draw grid
            drawGrid(context)
            
            // Draw layers
            for i in 0...data.sets.count - 1 {
                if layers[i] == nil {
                    let layer = Layer()
                    addSubview(layer)
                    layers[i] = layer
                }
                let layer = layers[i]!
                layer.data = data
                layer.index = i
                layer.graphHalfWidth = graphHalfWidth
                layer.frame = bounds
                layer.backgroundColor = UIColor.clearColor()
                if i < data.colors.count {
                    layer.color = data.colors[i]
                }
                layer.setNeedsDisplay()
            }
            
            for i in 0...data.axis.count - 1 {
                
                let userAttributes = [
                    NSFontAttributeName: font
                ]
                
                let size = data.axis[i].sizeWithAttributes(userAttributes)
                
                let offset = getOffset(i, radius: Double(graphHalfWidth) + labelGap)
                
                let attributes = [
                    NSForegroundColorAttributeName: axisLabelColor,
                    NSFontAttributeName: font
                ]
                
                let text = data.axis[i] as NSString
                
                var rect = CGRectZero
                
                rect.origin.x = center.x + offset.x
                if offset.x < 0 {
                    rect.origin.x -= size.width
                }
                rect.origin.y = center.y + offset.y
                if offset.y < 0 {
                    rect.origin.y -= size.height
                }
                
                let left = rect.origin.x
                if left < 0 {
                    rect.origin.x -= left
                }
                
                let right = rect.origin.x + size.width - bounds.width
                if right > 0 {
                    rect.origin.x -= right
                }
                
                rect.size = size
                
                text.drawInRect(rect, withAttributes: attributes)
                
            }
            
            UIGraphicsEndImageContext()
        }
    }
    
    func getOffset(axisIndex: Int, radius: Double) -> CGPoint {
        let axisCount = data.axis.count
        let angle = M_PI * 2.0 / Double(axisCount) * Double(axisIndex)
        let x = CGFloat(cos(angle) * radius)
        let y = CGFloat(sin(angle) * radius)
        return CGPointMake(x, y)
    }
    
    func drawGrid(context: CGContextRef) {
        let center = CGPointMake(bounds.width / 2, bounds.height / 2)
        let num = ceil(data.max / data.minUnit)
        
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context, gridLineColor.CGColor)
        
        for i in 1...Int(num) {
            let radius = graphHalfWidth * CGFloat(i) / CGFloat(num)
            let circleRect = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2)
            CGContextAddEllipseInRect(context, circleRect)
            CGContextStrokePath(context)
        }
        
        let axisCount = data.axis.count
        for i in 0...data.axis.count - 1 {
            let angle = M_PI * 2.0 / Double(axisCount) * Double(i)
            let x = center.x + CGFloat(cos(angle) * Double(graphHalfWidth))
            let y = center.y + CGFloat(sin(angle) * Double(graphHalfWidth))
            
            CGContextMoveToPoint(context, center.x, center.y)
            CGContextAddLineToPoint(context, x, y)
        }
        
        CGContextStrokePath(context);
    }
}