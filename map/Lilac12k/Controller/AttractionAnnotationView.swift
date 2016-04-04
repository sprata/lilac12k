import UIKit
import MapKit

class AttractionAnnotationView: MKAnnotationView {
    // Required for MKAnnotationView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Called when drawing the AttractionAnnotationView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat, color: UIColor) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
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
        
        color.setFill()
        //UIRectFill(finalSize)
        //setFill()
        
        theImageView.image = theImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        theImageView.tintColor = UIColor.redColor()
        
        theImageView.image!.drawInRect(CGRectMake(0, 0, finalSize.width, 75))
        roundedImage!.drawInRect(CGRectMake(finalSize.width/2-newWidth/2, 3, newWidth, newHeight))//(areaSize)
        
        let finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
        
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let attractionAnnotation = self.annotation as! AttractionAnnotation
        var color = UIColor(red: 250/255, green: 121/255, blue: 33/255, alpha: 1.0)
        switch (attractionAnnotation.type) {
        case .AttractionFirstAid:
            image = UIImage(named: "firstaid")
        case .AttractionFood:
            image = UIImage(named: "food")
        case .AttractionWater:
            image = UIImage(named: "water")
        case .ProfilePicture:
            switch (attractionAnnotation.color) {
            case .color1:
                color = UIColor(red: 250/255, green: 121/255, blue: 33/255, alpha: 1.0)
            case .color2:
                color = UIColor(red: 91/255, green: 192/255, blue: 235/255, alpha: 1.0)
            case .color3:
                color = UIColor(red: 155/255, green: 197/255, blue: 61/255, alpha: 1.0)
            case .color4:
                color = UIColor(red: 229/255, green: 89/255, blue: 52/255, alpha: 1.0)
            case .color5:
                color = UIColor(red: 253/255, green: 231/255, blue: 76/255, alpha: 1.0)
            }
            image = resizeImage(FacebookImages.sharedInstance.dictionaryOfProfilePictures[attractionAnnotation.desc!]!, newWidth: 50, color: color)
        default:
            image = UIImage(named: "star")
        }
    }
    
}