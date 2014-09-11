//
//  WalkOverlayViewController.swift
//  DrunkardsWalk
//
//  Created by Jeff Gayle on 9/8/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import UIKit

protocol AnimationEngineDelegate {
    func pinHasFinishedAnimation()
}

class AnimationEngine: NSObject {
    
    var timer : NSTimer!
    var imageView : UIImageView!
    var points = [CGPoint]()
    var pointNumber = 0
    var numberOfPoints = 0
    var imageViewArray = [UIImageView]()
    
    var rotation : CGAffineTransform!
    var quadrant : Int!

    var delegate : AnimationEngineDelegate?

    var view : UIView!
    
    init(view: UIView, points: [CGPoint]) {
        self.view = view
        self.points = points
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.animatePathBetweenTwoPoints(self.points[0], destination: self.points[1])
//        // Do any additional setup after loading the view.
//    }
//    
    func animatePathBetweenTwoPoints(source: CGPoint, destination: CGPoint) {
        let leftFoot = UIImage(named: "humanLeftFoot18pxStraight")
        self.imageView = UIImageView()
        self.imageView.image = leftFoot
        self.imageView.frame = CGRectMake(source.x, source.y - 60, 10, 10)
        self.imageViewArray.append(self.imageView)
        self.view.addSubview(self.imageView)
        
        var tuple = self.angleBetweenTwoPoints(source, point2: destination)
        self.rotation = tuple.transform
        self.quadrant = tuple.quadrant
        
        self.viewAnimation(destination)
    }
    
    func viewAnimation(destination: CGPoint) {
        UIView.animateWithDuration(5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.imageView.frame = CGRect(x: destination.x, y: destination.y - 60, width: self.imageView.frame.width, height: self.imageView.frame.height)
            self.imageView.hidden = true
            
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "getPoint", userInfo: nil, repeats: true)
            }) { (success) -> Void in
                self.timer.invalidate()
                self.numberOfPoints++
                if self.numberOfPoints < self.points.count - 1 {
                    var point = self.points[self.numberOfPoints]
                    var pointPlusOne = self.points[self.numberOfPoints + 1]
                    self.animatePathBetweenTwoPoints(point, destination: pointPlusOne)
                    
                } else {
                    self.delegate?.pinHasFinishedAnimation()
                }
                
        }
    }
    
    func getPoint() {
        var currentRect = self.imageView.layer.presentationLayer().frame as CGRect
        if let lastImageView = self.imageViewArray.last {
            let distanceBetweenX = abs(currentRect.origin.x - lastImageView.frame.origin.x)
            let distanceBetweenY = abs(currentRect.origin.y - lastImageView.frame.origin.y)
            
            if distanceBetweenX > 8 || distanceBetweenY > 8 {
                if self.pointNumber % 2 == 0 {
                    self.addLeftFootImage(CGPointMake(currentRect.origin.x, currentRect.origin.y))
                } else {
                    self.addRightFootImage(CGPointMake(currentRect.origin.x, currentRect.origin.y))
                }
                self.pointNumber++
            }
        }
    }
    
    func addLeftFootImage(point: CGPoint) {
        let leftFoot = UIImage(named: "humanLeftFoot18pxStraight")
        let imageView = UIImageView(image: leftFoot)
        
        switch self.quadrant {
        case 1:
            imageView.frame = CGRectMake(point.x + 5, point.y - 5, 10, 10)
        case 2:
            imageView.frame = CGRectMake(point.x - 3, point.y - 5, 10, 10)
        case 3:
            imageView.frame = CGRectMake(point.x + 3, point.y + 7, 10, 10)
        case 4:
            imageView.frame = CGRectMake(point.x - 3, point.y + 3, 10, 10)
        default:
            imageView.frame = CGRectMake(point.x, point.y, 10, 10)
        }
        imageView.transform = self.rotation!
        
        
        self.imageViewArray.append(imageView)
        
        self.view.addSubview(imageView)
    }
    
    func addRightFootImage(point: CGPoint) {
        let rightFoot = UIImage(named: "humanRightFoot18pxStraight")
        let imageView = UIImageView(image: rightFoot)
        
        switch self.quadrant {
        case 1:
            imageView.frame = CGRectMake(point.x + 3, point.y + 3, 10, 10)
        case 2:
            imageView.frame = CGRectMake(point.x, point.y, 10, 10)
        case 3:
            imageView.frame = CGRectMake(point.x - 3, point.y - 3, 10, 10)
        case 4:
            imageView.frame = CGRectMake(point.x + 3, point.y - 3 , 10, 10)
        default:
            imageView.frame = CGRectMake(point.x, point.y, 10, 10)
        }
        
        imageView.transform = self.rotation!
        
        self.imageViewArray.append(imageView)
        
        self.view.addSubview(imageView)
    }
    
    func angleBetweenTwoPoints(point1: CGPoint, point2: CGPoint) -> (transform: CGAffineTransform, quadrant: Int)   {
        let piMultiplier = 180 / M_PI
        
        var dx = point1.x - point2.x
        var dy = point1.y - point2.y
        
        var rotationTransform = CGAffineTransformIdentity
        
        if point1.x > point2.x && point1.y > point2.y {
            var angle_X_Y = atan2(dx, dy)
            var degreeAngle_X_Y = angle_X_Y * CGFloat(piMultiplier)
            rotationTransform = CGAffineTransformMakeRotation(degreeAngle_X_Y)
            return (rotationTransform, 4)
            
        } else if point1.x < point2.x && point1.y < point2.y {
            var angleXY = atan2(-dx, -dy)
            var degreeAngleXY = angleXY * CGFloat(piMultiplier)
            rotationTransform = CGAffineTransformMakeRotation(-degreeAngleXY)
            return (rotationTransform, 1)
            
        } else if point1.x > point2.x && point1.y < point2.y {
            var angle_XY = atan2(dx, -dy)
            var degreeAngle_XY = angle_XY * CGFloat(piMultiplier)
            rotationTransform = CGAffineTransformMakeRotation(degreeAngle_XY)
            return (rotationTransform, 3)
            
        } else {
            var angleX_Y = atan2(-dx, dy)
            var degreeAngleX_Y = angleX_Y * CGFloat(piMultiplier)
            rotationTransform = CGAffineTransformMakeRotation(degreeAngleX_Y)
            return (rotationTransform, 2)
        }
    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
