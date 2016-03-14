//
//  PinImages.swift
//  Lilac12k
//
//  Created by Sarah Prata on 3/11/16.
//  Copyright © 2016 codemysource. All rights reserved.
//

import Foundation


import CoreData

public class PinImages : UIImage {
    
    /*func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))//imageView.bounds.size)
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        let imageView: UIImageView = UIImageView(image: newImage)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(newImage.size.width/2)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //now add pin to background
        let mapPin = UIImage(named: "map_pin55x75_black.png")
        let theImageView : UIImageView = UIImageView(image: mapPin)
        
        
        
        let finalSize = CGSize(width: 55, height: 150)
        UIGraphicsBeginImageContext(finalSize)
        UIColor.purpleColor().setFill()
        //UIRectFill(finalSize)
        //setFill()
        theImageView.image = theImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        theImageView.tintColor = UIColor.purpleColor()
        
        
        theImageView.image!.drawInRect(CGRectMake(0, 0, finalSize.width, 75))
        roundedImage!.drawInRect(CGRectMake(finalSize.width/2-newWidth/2, 8, newWidth, newHeight))//(areaSize)
        
        let finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
        
    }
    
    init(nameOfPerson: String)
    {
        resizeImage(resizeImage(FacebookImages.sharedInstance.dictionaryOfProfilePictures[nameOfPerson]!, newWidth: 40))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required convenience public init(imageLiteral name: String) {
        fatalError("init(imageLiteral:) has not been implemented")
    }*/
}