//: Playground - noun: a place where people can play

import UIKit
import CoreLocation


///GPS provides an API for many of the amazing details you can determine from GPS coordinates
public class GPS {
    public var latitude:Double
    public var longitude:Double
    
    public init(latitude:Double, longitude:Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    ///Distance to a point using the Equitectangular measuersa
    public func distanceToEquirectangular(gps:GPS) -> Double {
        return GPS.distanceBetweenEquirectangular(f: self, s: gps)
    }
    
    ///Distance to a point using the Haversine formula (miles)
    public func distanceToHaversine(gps:GPS) -> Double {
        return GPS.distanceBetweenHaversine(f: self, s: gps)
    }
    
    ///Returns the GPS coordinates on the other side of the world. (If you were to dig a hole perfectly straight this is where you would end up)
    public func oppositeCoordinate(gps:GPS) -> GPS {
        return oppositeCoordinate(gps: self)
    }
    
     
    
    //STATIC VARS
    
    public static let MAX_LATITUDE:Double = +90.0
    public static let MIN_LATITUDE:Double = -90.0
    public static let MIN_LONGITUDE:Double = -180.0
    public static let MAX_LONGITUDE:Double = 180.0
    ///The Radius of earth in miles
    public static var EARTH_RADIUS:Double = 3959.0
    ///The Radius of earth in kilometers. (Get only)
    public static var EARTH_RADIUS_METRIC:Double {
        get {
            return EARTH_RADIUS * 1.60934
        }
    }
    
    //STATIC FUNCS
    
    ///Returns the distance from point f to point s in miles using the haversine formula
    public static func distanceBetweenHaversine(f:GPS,s:GPS) -> Double {
        let long1 = degreesToRadians(degrees: f.longitude)
        let long2 = degreesToRadians(degrees: s.longitude)
        let lat1 = degreesToRadians(degrees: f.latitude)
        let lat2 = degreesToRadians(degrees: s.latitude)
        let longDifference = abs(long1 - long2)
        let latDifference = abs(lat1 - lat2)
        let a = pow(sin(latDifference/2), 2) + cos(lat1) * cos(lat2) * pow(sin(longDifference/2), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return c * EARTH_RADIUS
    }
    
    ///Returns the distance from point f to point s in kilometers using the haversine formula
    public static func distanceBetweenHaversineMetric(f:GPS,s:GPS) -> Double {
        let long1 = degreesToRadians(degrees: f.longitude)
        let long2 = degreesToRadians(degrees: s.longitude)
        let lat1 = degreesToRadians(degrees: f.latitude)
        let lat2 = degreesToRadians(degrees: s.latitude)
        let longDifference = abs(long1 - long2)
        let latDifference = abs(lat1 - lat2)
        let a = pow(sin(latDifference/2), 2) + cos(lat1) * cos(lat2) * pow(sin(longDifference/2), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return c * EARTH_RADIUS_METRIC
    }
    
    ///Returns the distance from point f to point s in miles using the equirectangular formula (signicantly less acurate than haversine but faster)
    public static func distanceBetweenEquirectangular(f:GPS,s:GPS) -> Double {
        //calculate arc length between two line segment tips
        //arc length = radius times angle in radians
        let longDifference = abs(f.longitude - s.longitude)
        let latDifference = abs(f.latitude - s.latitude)
        let combinedArc = combineArcLengths(arcOne: longDifference, arcTwo: latDifference)
        let arcAsRadians = degreesToRadians(degrees: combinedArc)
        let distance = EARTH_RADIUS * arcAsRadians
        return distance
    }
    ///Returns the distance from point f to point s in kilometers using the equirectangular formula (signicantly less acurate than haversine but faster)
    public static func distanceBetweenEquirectangularMetric(f:GPS,s:GPS) -> Double {
        let longDifference = abs(f.longitude - s.longitude)
        let latDifference = abs(f.latitude - s.latitude)
        let combinedArc = combineArcLengths(arcOne: longDifference, arcTwo: latDifference)
        let arcAsRadians = degreesToRadians(degrees: combinedArc)
        let distance = EARTH_RADIUS_METRIC * arcAsRadians
        return distance
    }
    
    ///Returns the heading that points towards s from f
    public static func headingBetweenCoordinates(f:GPS,s:GPS) -> Double {
        return radiansToDegrees(radians: atan2(s.latitude - f.latitude, s.longitude - f.longitude))
    }
    
    ///Returns the GPS coordinates on the other side of the world. (If you were to dig a hole perfectly straight this is where you would end up)
    public static func oppositeCoordinate(gps:GPS) -> GPS {
        return GPS(latitude: -gps.latitude,longitude: -gps.longitude)
    }
    ///Convert decimal format coordinates to degrees, minutes, seconds
    public static func toDegreesMinuteSecond(coordinate:Double) -> (degrees:Double,minutes:Double,seconds:Double) {
        let degrees = floor(coordinate)
        let minutes = floor((coordinate - degrees) * 60)
        let seconds = (((coordinate - degrees) * 60) - minutes) * 60
        
        return (degrees,minutes,seconds)
    }
    ///convert degrees minutes and seconds to decimal format
    public static func toDecimal(degrees:Double,minutes:Double,seconds:Double) -> Double {
        return degrees + minutes / 60 + seconds / 3600
    }
    ///The distance to the horizon in miles. Doesn't take refraction into account (Height in feet)
    public static func distanceToHorizon(atHeight:Double) -> Double {
        return sqrt(2 * EARTH_RADIUS * atHeight/5280 + pow(atHeight/5280,2))
    }
    
    /*
    ///Get the GPS coordnates x miles north and x miles east from gps
    public static func translateImperial(gps:GPS,north:Double,east:Double) -> GPS {
        let long1 = degreesToRadians(degrees: gps.longitude)
        //let long2 = degreesToRadians(degrees: s.longitude)
        let lat1 = degreesToRadians(degrees: gps.latitude)
        //let lat2 = degreesToRadians(degrees: s.latitude)
        //let longDifference = abs(long1 - long2)
        //let latDifference = abs(lat1 - lat2)
        let distance = sqrt(pow(north, 2) + pow(east, 2))
        let angle = distance/EARTH_RADIUS
        
        //let a = pow(sin(latDifference/2), 2) + cos(lat1) * cos(lat2) * pow(sin(longDifference/2), 2)
        //let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return c * EARTH_RADIUS
    }*/
    
    
    
    
    
    
    //Helper functions
    private static func combineArcLengths(arcOne:Double, arcTwo:Double) -> Double {
        return sqrt(pow(arcOne, 2) + pow(arcTwo, 2))
    }
    private static func degreesToRadians(degrees:Double) -> Double {
        return degrees/57.295779513082321
    }
    private static func radiansToDegrees(radians:Double) -> Double {
        return 57.295779513082321 * radians
    }
    
    
}

let gps1 = GPS(latitude: 40.9078414, longitude: -74.0105259)
let gps2 = GPS(latitude: 40.9003490, longitude: -73.9089020)
let gps3 = GPS(latitude: 0, longitude: 0)
let gps4 = GPS(latitude: 1, longitude: 0)
print(GPS.headingBetweenCoordinates(f: gps2, s: gps1))
print(GPS.distanceBetweenEquirectangular(f: gps1, s: gps2))
print(GPS.distanceBetweenHaversine(f: gps1, s: gps2))

let test = GPS.toDegreesMinuteSecond(coordinate: gps1.latitude)
GPS.toDecimal(degrees: test.degrees, minutes: test.minutes, seconds: test.seconds)
GPS.distanceToHorizon(atHeight: 29029)


