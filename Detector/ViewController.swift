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
        
        personPic.image = UIImage(named: "face-8")

        detect()
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
            
            let eyeSize = CGSize(width: 5, height: 5)
            
            if face.hasLeftEyePosition {
                print("Left eye bounds are \(face.leftEyePosition)")
            }
            
            var leftEyeBounds = CGRect(x: face.leftEyePosition.x, y: face.leftEyePosition.y, width: eyeSize.width, height: eyeSize.height).applying(transform)
            
            leftEyeBounds = leftEyeBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            leftEyeBounds.origin.x += offsetX
            leftEyeBounds.origin.y += offsetY
            
            let leftEyeBox = UIView(frame: leftEyeBounds)
            leftEyeBox.layer.borderWidth = 3
            leftEyeBox.layer.borderColor = UIColor.red.cgColor
            leftEyeBox.backgroundColor = UIColor.clear
            personPic.addSubview(leftEyeBox)
            
            if face.hasRightEyePosition {
                print("Right eye bounds are \(face.rightEyePosition)")
            }
            
            var rightEyeBounds = CGRect(x: face.rightEyePosition.x, y: face.rightEyePosition.y, width: eyeSize.width, height: eyeSize.height).applying(transform)
            
            rightEyeBounds = rightEyeBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            rightEyeBounds.origin.x += offsetX
            rightEyeBounds.origin.y += offsetY
            
            let rightEyeBox = UIView(frame: rightEyeBounds)
            rightEyeBox.layer.borderWidth = 3
            rightEyeBox.layer.borderColor = UIColor.red.cgColor
            rightEyeBox.backgroundColor = UIColor.clear
            personPic.addSubview(rightEyeBox)
        }
    }
    
}
