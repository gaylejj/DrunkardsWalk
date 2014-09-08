//
//  WalkOverlayViewController.swift
//  DrunkardsWalk
//
//  Created by Jeff Gayle on 9/8/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import UIKit

class WalkOverlayViewController: UIViewController {
    
    var timer : NSTimer!
    var imageView : UIImageView!
    var points = [CGPoint]()
    var pointNumber = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func animatePathBetweenTwoPoints(source: CGPoint, destination: CGPoint) {
        
        let leftFoot = UIImage(named: "humanLeftFoot18pxStraight")
        self.imageView = UIImageView()
        self.imageView.image = leftFoot
        self.imageView.frame = CGRectMake(source.x, source.y, 10, 10)
        self.view.addSubview(self.imageView)
        
        self.viewAnimation(destination)
    }
    
    func viewAnimation(destination: CGPoint) {
        UIView.animateWithDuration(5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.imageView.frame = CGRect(x: destination.x, y: destination.y, width: self.imageView.frame.width, height: self.imageView.frame.height)
            self.imageView.hidden = true
            
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "getPoint", userInfo: nil, repeats: true)
            }) { (success) -> Void in
                self.timer.invalidate()
        }
    }
    
    func getPoint() {
        var currentRect = self.imageView.layer.presentationLayer().frame as CGRect
        if self.pointNumber % 2 == 0 {
            self.addLeftFootImage(CGPointMake(currentRect.origin.x, currentRect.origin.y))
        } else {
            self.addRightFootImage(CGPointMake(currentRect.origin.x, currentRect.origin.y))
        }
        self.pointNumber++
    }
    
    func addLeftFootImage(point: CGPoint) {
        let leftFoot = UIImage(named: "humanLeftFoot18pxStraight")
        let imageView = UIImageView(image: leftFoot)
        imageView.frame = CGRectMake(point.x - 3, point.y + 2, 10, 10)
        
        self.view.addSubview(imageView)
    }
    
    func addRightFootImage(point: CGPoint) {
        let rightFoot = UIImage(named: "humanRightFoot18pxStraight")
        let imageView = UIImageView(image: rightFoot)
        imageView.frame = CGRectMake(point.x + 3, point.y - 2, 10, 10)
        
        self.view.addSubview(imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
