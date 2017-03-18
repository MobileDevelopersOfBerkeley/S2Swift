//
//  S2LatLng.swift
//  Sphere2
//


import Foundation

//package s2
// import fmt, math, s1

let northPoleLat = .pi / 2.0
let southPoleLat = -.pi / 2.0

// LatLng represents a point on the unit sphere as a pair of angles.
struct LatLng {
  let lat: Double
  let lng: Double

  // MARK: inits / factory
  
  init(lat: Double, lng: Double) {
    self.lat = lat
    self.lng = lng
  }
  
  init(latDegrees: Double, lngDegrees: Double) {
    self.lat = latDegrees * toRadians
    self.lng = lngDegrees * toRadians
  }
  
  // LatLngFromPoint returns an LatLng for a given Point.
  init(point: S2Point) {
    self.init(lat: point.latitude(), lng: point.longitude())
  }
  
  // MARK: protocols
  
  var description: String {
    let lat2 = String(format: "%.7f", lat * toDegrees)
    let lng2 = String(format: "%.7f", lng * toDegrees)
    return "[\(lat2), \(lng2)]"
  }
  
  // MARK: computed members
  
  // Normalized returns the normalized version of the LatLng,
  // with Lat clamped to [-π/2,π/2] and Lng wrapped in [-π,π].
  func normalize() -> LatLng {
    var lat2 = lat
    if lat2 > northPoleLat {
      lat2 = northPoleLat
    } else if lat2 < southPoleLat {
      lat2 = southPoleLat
    }
    let lng2 = remainder(lng, 2.0 * .pi)
    return LatLng(lat: lat2, lng: lng2)
  }
  
  // MARK: tests
  
  // IsValid returns true iff the LatLng is normalized, with Lat ∈ [-π/2,π/2] and Lng ∈ [-π,π].
  func isValid() -> Bool {
    return fabs(lat) <= .pi/2 && fabs(lng) <= .pi
  }

  // MARK: arithmetic
  
  // Distance returns the angle between two LatLngs.
  func distance(_ latLng: LatLng) -> Double {
    // Haversine formula, as used in C++ S2LatLng::GetDistance.
    let lat1 = lat
    let lat2 = latLng.lat
    let lng1 = lng
    let lng2 = latLng.lng
    let dlat = sin(0.5 * (lat2 - lat1))
    let dlng = sin(0.5 * (lng2 - lng1))
    let x = dlat * dlat + dlng * dlng * cos(lat1) * cos(lat2)
    return 2 * atan2(sqrt(x), sqrt(max(0, 1-x)))
  }

  // NOTE(mikeperrow): The C++ implementation publicly exposes latitude/longitude
  // functions. Let's see if that's really necessary before exposing the same functionality.

  static func latitude(_ vector: R3Vector) -> Double {
    return atan2(vector.z, sqrt(vector.x * vector.x + vector.y * vector.y))
  }
  
  static func longitude(_ vector: R3Vector) -> Double {
    return atan2(vector.y, vector.x)
  }
  
  // PointFromLatLng returns an Point for the given LatLng.
  func toPoint() -> S2Point {
    return S2Point(latLng: self)
  }
  
}
