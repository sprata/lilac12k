import UIKit
import MapKit

enum AttractionType: Int {
    case AttractionDefault = 0
    case AttractionRide = 1
    case AttractionFood = 2
    case AttractionFirstAid = 3
    case ProfilePicture = 4
    case AttractionWater = 5
}

enum AttractionColor: Int {
    case color1 = 0
    case color2 = 1
    case color3 = 2
    case color4 = 3
    case color5 = 4
}

class AttractionAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: AttractionType
    var desc: String?
    var color: AttractionColor
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: AttractionType) {
        self.coordinate = coordinate
        self.title = title
        self.type = type
        self.desc = nil
        self.subtitle = subtitle
        self.color = AttractionColor(rawValue: 0)!
    }
    init(coordinate: CLLocationCoordinate2D, title: String, desc: String, type: AttractionType, color: AttractionColor) {
        self.coordinate = coordinate
        self.title = title
        self.type = type
        if(type == AttractionType(rawValue: 4))
        {
            self.desc = desc
        }
        self.subtitle = nil
        self.color = color
    }
    override init() {
        self.coordinate = CLLocationCoordinate2DMake(0.0, 0.0)
        self.title = nil
        self.type = AttractionType(rawValue: 4)!
        self.subtitle = nil
        self.color = AttractionColor(rawValue: 0)!
    }
}