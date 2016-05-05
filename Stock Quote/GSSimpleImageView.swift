//
//  GSSimpleImageView.swift
//  GSSimpleImage
//
//  Created by 胡秋实 on 1/16/2016.
//  Modified and enhanced by Ruya Gong on 5/1/2016
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class GSSimpleImageView: UIImageView {
    
    var bgView: UIView!
    var imageV: UIImageView!
    var scale: CGFloat = 1
    var fullScreen: Bool = false
    var HDUrl: NSURL?
    
    //MARK: Life cycle
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTapGesture()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationChanged), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTapGesture()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationChanged), name: UIDeviceOrientationDidChangeNotification, object: nil)
        //fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Private methods
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(fullScreenMe))
        self.addGestureRecognizer(tap)
        self.userInteractionEnabled = true
    }
    //MARK: Actions of Gestures
    func exitFullScreen() {
        self.fullScreen = false
        UIView.animateWithDuration(0.2, animations: {
                self.bgView.alpha = 0
            }, completion: { finished in
                self.bgView.removeFromSuperview()
        })
    }
    
    func fullScreenMe() {
        if let window = UIApplication.sharedApplication().delegate?.window {
            self.fullScreen = true
            self.bgView = UIView(frame: UIScreen.mainScreen().bounds)
            self.bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitFullScreen)))
            self.bgView.backgroundColor = UIColor.blackColor()
            
            self.bgView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoom)))
            self.bgView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(drag)))
            
            self.imageV = UIImageView(image: self.image)
            self.imageV.frame = self.bgView.frame
            self.imageV.contentMode = .ScaleAspectFit
            self.bgView.addSubview(imageV)
            window?.addSubview(bgView)

            var sx:CGFloat=0, sy:CGFloat=0
            if self.frame.size.width > self.frame.size.height {
                sx = self.frame.size.width/imageV.frame.size.width
                self.imageV.transform = CGAffineTransformMakeScale(sx, sx)
            } else {
                sy = self.frame.size.height/imageV.frame.size.height
                self.imageV.transform = CGAffineTransformMakeScale(sy, sy)
            }
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.imageV.transform = CGAffineTransformMakeScale(1, 1)
            })
            
            if HDUrl != nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: self.HDUrl!)
                    if data == nil {
                        print("Network failed")
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            let theImage = UIImage(data: data!)
                            self.imageV.image = theImage
                        }
                    }
                }
            }
        }
    }
    func zoom(sender:UIPinchGestureRecognizer) {
        if sender.state == .Ended || sender.state == .Changed {
            let currentScale = self.imageV.frame.size.width / self.imageV.bounds.size.width
            self.scale = currentScale * sender.scale
            self.scale = max(1, self.scale)
            self.scale = min(3, self.scale)
            let transform = CGAffineTransformMakeScale(self.scale, self.scale)
            self.imageV.transform = transform
            sender.scale = 1
            self.imageV.center = restrictImage(self.imageV.center)
        }
    }
    func drag(sender:UIPanGestureRecognizer) {
        let translation = sender.translationInView(imageV)
        self.imageV.center = restrictImage(CGPoint(
            x: self.imageV.center.x + translation.x * scale,
            y: self.imageV.center.y + translation.y * scale
        ))
        sender.setTranslation(CGPointZero, inView: imageV)
    }
    func restrictImage(center: CGPoint) -> CGPoint {
        var newX = center.x
        var newY = center.y
        newX = min(newX, self.imageV.frame.size.width * 0.5)
        newX = max(newX, self.bgView.frame.size.width - self.imageV.frame.size.width * 0.5)
        newY = min(newY, self.imageV.frame.size.height * 0.5)
        newY = max(newY, self.bgView.frame.size.height - self.imageV.frame.size.height * 0.5)
        return CGPoint(x: newX, y: newY)
    }
    func orientationChanged() {
        if self.fullScreen {
            self.bgView.frame = UIScreen.mainScreen().bounds
            self.imageV.frame.size.height = self.scale * self.bgView.frame.size.height
            self.imageV.frame.size.width = self.scale * self.bgView.frame.size.width
            self.imageV.center = restrictImage(self.imageV.center)
        }
    }
}