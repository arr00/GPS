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
    
    
    ///Distance to a point using the Equitectangular formula. Units will match planet radius units
    public func distanceToEquirectangular(gps:GPS) -> Double {
        return GPS.distanceBetweenEquirectangular(f: self, s: gps)
    }
    
    ///Distance to a point using the Haversine formula. Units will match planet radius units
    public func distanceToHaversine(gps:GPS) -> Double {
        return GPS.distanceBetweenHaversine(f: self, s: gps)
    }
    
    ///Returns the GPS coordinates on the other side of the world. (If you were to dig a hole perfectly straight this is where you would end up)
    public func oppositeCoordinate() -> GPS {
        return GPS.oppositeCoordinate(gps: self)
    }
    
     
    
    //STATIC VARS
    
    public static let MAX_LATITUDE:Double = +90.0
    public static let MIN_LATITUDE:Double = -90.0
    public static let MIN_LONGITUDE:Double = -180.0
    public static let MAX_LONGITUDE:Double = 180.0
    ///The Radius of earth in miles
    public static let EARTH_RADIUS:Double = 3959.0
    ///The Radius of earth in kilometers.
    public static let EARTH_RADIUS_METRIC:Double = EARTH_RADIUS * 1.60934
    ///The Radius of the Moon in miles
    public static let MOON_RADIUS:Double = 1079.0
    ///The radius of the moon in kilometers
    public static let MOON_RADIUS_METRIC:Double = MOON_RADIUS * 1.60934
    ///Radius of Mars (Miles)
    public static let MARS_RADIUS:Double = 2106.0
    ///Radius of Mars (Kilometers)
    public static let MARS_RADIUS_METRIC:Double = MARS_RADIUS * 1.60934
    ///Planet Radius used for calculations
    public static var planetRadius = EARTH_RADIUS
    
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
        return c * planetRadius
    }
    
    /*
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
    }*/
    
    ///Returns the distance from point f to point s using the equirectangular formula (signicantly less acurate than haversine but faster). Units will match planet radius units
    public static func distanceBetweenEquirectangular(f:GPS,s:GPS) -> Double {
        //calculate arc length between two line segment tips
        //arc length = radius times angle in radians
        let longDifference = abs(f.longitude - s.longitude)
        let latDifference = abs(f.latitude - s.latitude)
        let combinedArc = combineArcLengths(arcOne: longDifference, arcTwo: latDifference)
        let arcAsRadians = degreesToRadians(degrees: combinedArc)
        let distance = planetRadius * arcAsRadians
        return distance
    }
    /*
    ///Returns the distance from point f to point s in kilometers using the equirectangular formula (signicantly less acurate than haversine but faster)
    public static func distanceBetweenEquirectangularMetric(f:GPS,s:GPS) -> Double {
        let longDifference = abs(f.longitude - s.longitude)
        let latDifference = abs(f.latitude - s.latitude)
        let combinedArc = combineArcLengths(arcOne: longDifference, arcTwo: latDifference)
        let arcAsRadians = degreesToRadians(degrees: combinedArc)
        let distance = EARTH_RADIUS_METRIC * arcAsRadians
        return distance
    }*/
    
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
    ///The distance to the horizon in miles. Planet radius must be in miles. Doesn't take refraction into account (Height in feet).
    public static func distanceToHorizon(atHeight:Double) -> Double {
        return sqrt(2 * planetRadius * atHeight/5280 + pow(atHeight/5280,2))
    }
    ///Distance to the horizon in kilometers. Planet radius must be in kilometers. Doesn't take refraction into account (Height in meters).
    public static func distanceToHorizonMetric(atHeight:Double) -> Double {
        return sqrt(2 * planetRadius * atHeight/1000 + pow(atHeight/1000,2))
    }
    
    ///Helper function for sunrise and sunset #DRY
    private static func sunriseSunsetHelper(gps:GPS, date:Date, sunZenith:SunZenith, sunPhase:SunPhase) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Etc/UTC")!
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        let n1 = floor(275.0 * Double(month) / 9)
        let n2 = floor((Double(month) + 9.0) / 12.0)
        let n3 = (1 + floor((Double(year) - 4 * floor(Double(year) / 4) + 2) / 3))
        let n = n1 - (n2 * n3) + Double(day) - 30
        
        let longHour = gps.longitude/15.0
        
        var t = Double()
        
        switch sunPhase {
        case .sunrise:
            t = n + ((6 - longHour) / 24.0)
        case .sunset:
            t = n + ((18.0 - longHour) / 24.0)
        default:
            print("Do later")
        }
        
        let m = (0.9856 * t) - 3.289
        
        var l = m + (1.916 * mySin(degrees:m)) + (0.020 * mySin(degrees:(2 * m))) + 282.634
        
        if l >= 360 {
            l -= 360
        }
        else if l < 0 {
            l += 360
        }
        
        
        var ra = myAtan(degrees: 0.91764 * myTan(degrees: l))
        
        if ra >= 360 {
            ra -= 360
        }
        else if ra < 0 {
            ra += 360
        }
        
        let Lquadrant  = (floor(l/90.0)) * 90.0
        let RAquadrant = (floor(ra/90.0)) * 90.0
        ra += (Lquadrant - RAquadrant)
        
        ra /= 15
        
        let sinDec = 0.39782 * mySin(degrees: l)
        let cosDec = myCos(degrees: myAsin(degrees:sinDec))
        
        let cosH = (myCos(degrees: sunZenith.rawValue) - (sinDec * mySin(degrees: gps.latitude))) / (cosDec * myCos(degrees: gps.latitude))
        
        print("cosH is \(cosH)")
        if cosH > 1 || cosH < -1 {
            return nil
        }
        
        
        
        //degreesToRadians(degrees: cosH)
        
        //radiansToDegrees(radians: acos(degreesToRadians(degrees: cosH)))
        var h = Double()
        switch sunPhase {
        case SunPhase.sunset:
            h = myAcos(degrees: cosH)
        case .sunrise:
            h = 360 - myAcos(degrees: cosH)
        default:
            print("Do later")
        }
        
        h /= 15
        
        let time = h + ra - (0.06571 * t) - 6.622
        
        var ut = time - longHour
        if ut > 24 {
            ut -= 24
        }
        else if ut < 0 {
            ut += 24
        }
        
        var dateComponents = DateComponents()
        dateComponents.calendar = calendar
        dateComponents.timeZone = calendar.timeZone
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        Int(floor(ut))
        dateComponents.hour = Int(floor(ut))
        Int(((ut - floor(ut)) * 60))
        dateComponents.minute = Int(((ut - floor(ut)) * 60))
        
        let resultDate = calendar.date(from: dateComponents)
        
        
        return resultDate!
    }
    
    public static func sunsetTime(gps:GPS, date:Date, sunZenith:SunZenith) -> Date? {
        return sunriseSunsetHelper(gps: gps, date: date, sunZenith: sunZenith, sunPhase: .sunset)
    }
    public static func sunriseTime(gps:GPS, date:Date, sunZenith:SunZenith) -> Date? {
        return sunriseSunsetHelper(gps: gps, date: date, sunZenith: sunZenith, sunPhase: .sunrise)
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
        return degrees * (Double.pi/180)
    }
    private static func radiansToDegrees(radians:Double) -> Double {
        return (180/Double.pi) * radians
    }
    
    
    //Math helpers
    static func mySin(degrees: Double) -> Double {
        return __sinpi(degrees/180.0)
    }
    
    static func myCos(degrees: Double) -> Double {
        return __cospi(degrees/180.0)
    }
    
    static func myTan(degrees: Double) -> Double {
        return __tanpi(degrees/180.0)
    }
    
    static func myAtan(degrees: Double) -> Double {
        return Darwin.atan(degrees) * (180.0 / Double.pi)
    }
    
    static func myAcos(degrees: Double) -> Double {
        return Darwin.acos(degrees) * (180.0 / Double.pi)
    }
    
    static func myAsin(degrees: Double) -> Double {
        return Darwin.asin(degrees) * (180.0 / Double.pi)
    }
    
    
    ///Enum describing phases of the sun
    private enum SunPhase {
        case sunset
        case sunrise
        case midday
        case midnight
    }
    
    ///Enum describing the sun zenith
    public enum SunZenith:Double {
        case official = 90.888888
        case civil = 98
        case nautical = 102
        case astronomical = 108
    }
    
    
}

/*
let gps1 = GPS(latitude: 40.9078414, longitude: -74.0105259)
let gps2 = GPS(latitude: 40.9003490, longitude: -73.9089020)
let gps3 = GPS(latitude: 0, longitude: 0)
let gps4 = GPS(latitude: 1, longitude: 0)
print(GPS.headingBetweenCoordinates(f: gps2, s: gps1))
print(GPS.distanceBetweenEquirectangular(f: gps1, s: gps2))
print(GPS.distanceBetweenHaversine(f: gps1, s: gps2))

let test = GPS.toDegreesMinuteSecond(coordinate: gps1.latitude)
GPS.toDecimal(degrees: test.degrees, minutes: test.minutes, seconds: test.seconds)
GPS.distanceToHorizon(atHeight: 29029)*/

let gps = GPS(latitude: 40.908005, longitude: -74.010679)

let dateString = "01/01/2019"
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "mm/dd/yyyy"

//GPS.sunsetTime(gps: gps, date: dateFormatter.date(from: dateString)!)
//GPS.sunPhaseTime(gps: gps, date: dateFormatter.date(from: dateString)!, sunPhase: .sunrise, sunZenith: .official)
GPS.sunsetTime(gps: gps, date: dateFormatter.date(from: dateString)!, sunZenith: .official)

