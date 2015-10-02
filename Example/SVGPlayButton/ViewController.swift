//
//  ViewController.swift
//  SVGPlayButton
//
//  Created by Matthew Loseke on 10/02/2015.
//  Copyright (c) 2015 Matthew Loseke. All rights reserved.
//

import UIKit
import SVGPlayButton

class ViewController: UIViewController {
    
    @IBOutlet weak var progressButton: SVGPlayButton!
    
    @IBOutlet weak var resizeSlider: UISlider!
    
    var tickCount: Int = 0
    
    var totalCount: Int = 240
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressButton.willPlay = { self.progressButtonWillPlayHandler() }
        self.progressButton.willPause = { self.progressButtonWillPauseHandler() }
        self.resizeSlider.addTarget(self, action: "slideDragHandler:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("!!! MEMORY WARNING !!!")
        print("this controller has received a memory warning and should dispose of any resources that can be recreated")
    }
    
    func tickHandler() {
        
        self.progressButton.progressStrokeEnd = CGFloat(tickCount) / CGFloat(totalCount)
        
        if self.progressButton.progressStrokeEnd == 1.0 {
            tickCount = 0
            self.progressButton.resetProgressLayer()
        }
        
        tickCount++
    }
    
    func progressButtonWillPlayHandler() {
        
        //
        // If there is already timer, start it.
        // If there is NOT already a timer, create one and then start it.
        //
        if let timer = self.timer {
            timer.fire()
        } else {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01666, target: self, selector: "tickHandler", userInfo: nil, repeats: true)
        }
    }
    
    func progressButtonWillPauseHandler() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func slideDragHandler(sender: UISlider) {
        let val = CGFloat(sender.value)
        progressButton.transform = CGAffineTransformMakeScale(val, val);
        progressButton.setNeedsDisplay()
    }
    
}
