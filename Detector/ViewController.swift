//
//  ViewController.swift
//  Detector
//
//  Created by Gregg Mojica on 8/21/16.
//  Copyright © 2016 Gregg Mojica. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {
    @IBOutlet weak var personPic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personPic.image = UIImage(named: "djou-100")

        detect()
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to));
    }
    
    func plotEye(eyePosition: CGPoint, offsetX: CGFloat, offsetY: CGFloat, transform: CGAffineTransform, scale: CGFloat) {
        let eyeSize = CGSize(width: 5, height: 5)
        var eyeBounds = CGRect(x: eyePosition.x, y: eyePosition.y, width: eyeSize.width, height: eyeSize.height).applying(transform)
        
        eyeBounds = eyeBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
        eyeBounds.origin.x += offsetX
        eyeBounds.origin.y += offsetY
        
        let eyeBox = UIView(frame: eyeBounds)
        eyeBox.layer.borderWidth = 3
        eyeBox.layer.borderColor = UIColor.red.cgColor
        eyeBox.backgroundColor = UIColor.clear
        personPic.addSubview(eyeBox)
    }
    
    func detect() {
        
        guard let personciImage = CIImage(image: personPic.image!) else {
            return
        }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage)
        
        // Convert Core Image Coordinate to UIView Coordinate
        let ciImageSize = personciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        for face in faces as! [CIFaceFeature] {
            
            print("Found bounds are \(face.bounds)")
            
            // Apply the transform to convert the coordinates
            var faceViewBounds = face.bounds.applying(transform)
            
            // Calculate the actual position and size of the rectangle in the image view
            let viewSize = personPic.bounds.size
            let scale = min(viewSize.width / ciImageSize.width,
                            viewSize.height / ciImageSize.height)
            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
            let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
            
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            let faceBox = UIView(frame: faceViewBounds)
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            personPic.addSubview(faceBox)
            
            if face.hasLeftEyePosition && face.hasRightEyePosition {
                print("Left eye bounds are \(face.leftEyePosition)")
                plotEye(eyePosition: face.leftEyePosition, offsetX: offsetX, offsetY: offsetY, transform: transform, scale: scale)
                
                print("Right eye bounds are \(face.rightEyePosition)")
                plotEye(eyePosition: face.rightEyePosition, offsetX: offsetX, offsetY: offsetY, transform: transform, scale: scale)
                
                let distanceEyeToEye = CGPointDistance(from: face.leftEyePosition, to: face.rightEyePosition)
                print("The eye to eye distance is \(distanceEyeToEye)")
            }
        }
    }
    
}
