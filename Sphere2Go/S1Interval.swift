//
//  S2Interval.swift
//  Sphere2
//

import Foundation

// package s1
// import math, strconv


// S1Interval represents a closed interval on a unit circle.
// Zero-length intervals (where Lo == Hi) represent single points.
// If Lo > Hi then the interval is "inverted".
// The point at (-1, 0) on the unit circle has two valid representations,
// [π,π] and [-π,-π]. We normalize the latter to the former in S1IntervalFromEndpoints.
// There are two special intervals that take advantage of that:
//   - the full interval, [-π,π], and
//   - the empty interval, [π,-π].
// Treat the exported fields as read-only.
// The major differences from the C++ version are:
//   - no validity checking on construction, etc. (not a bug?)
//   - a few operations
struct S1Interval {
  
  //
  let lo: Double
  let hi: Double

  //
  static let epsilon = 1e-14

  // MARK: inits / factory
  
  init(lo: Double, hi: Double) {
    self.lo = lo
    self.hi = hi
  }
  
  // S1IntervalFromEndpoints constructs a new interval from endpoints.
  // Both arguments must be in the range [-π,π]. This function allows inverted intervals
  // to be created.
  init(lo_endpoint: Double, hi_endpoint: Double) {
    self.lo = lo_endpoint == -.pi && hi_endpoint != .pi ? .pi : lo_endpoint
    self.hi = hi_endpoint == -.pi && lo_endpoint != .pi ? .pi : hi_endpoint
  }
  
  // EmptyInterval returns an empty interval.
  static let empty = S1Interval(lo: .pi, hi: -.pi)

  // FullInterval returns a full interval.
  static let full = S1Interval(lo: -.pi, hi: .pi)

  // MARK: protocols
  
  var description: String {
    return "[\(lo), \(hi)]"
    // like "[%.7f, %.7f]"
//    return "[" + strconv.FormatFloat(Lo, 'f', 7, 64) + ", " + strconv.FormatFloat(hi, 'f', 7, 64) + "]"
  }
  
  // MARK: tests
  
  // isValid reports whether the interval is valid.
  func isValid() -> Bool {
    return fabs(lo) <= .pi && fabs(hi) <= .pi && !(lo == -.pi && hi != .pi) && !(hi == -.pi && lo != .pi)
  }

  // isFull reports whether the interval is full.
  func isFull() -> Bool {
    return hi - lo == 2 * .pi
  }

  // isEmpty reports whether the interval is empty.
  func isEmpty() -> Bool {
    return lo - hi == 2 * .pi
  }

  // isInverted reports whether the interval is inverted; that is, whether Lo > Hi.
  func isInverted() -> Bool {
    return lo > hi
  }

  // Center returns the midpoint of the interval.
  // It is undefined for full and empty intervals.
  func center() -> Double {
    let c = 0.5 * (lo + hi)
    if !isInverted() {
      return c
    }
    if c <= 0 {
      return c + .pi
    }
    return c - .pi
  }

  // Assumes p ∈ (-π,π].
  func fastContains(_ point: Double) -> Bool {
    if isInverted() {
      return (point >= lo || point <= hi) && !isEmpty()
    }
    return point >= lo && point <= hi
  }
  
  // Contains returns true iff the interval contains p.
  // Assumes p ∈ [-π,π].
  func contains(_ point: Double) -> Bool {
    if point == -.pi {
      return fastContains(.pi)
    }
    return fastContains(point)
  }
  
  // ContainsInterval returns true iff the interval contains other.
  func contains(_ interval: S1Interval) -> Bool {
    if isInverted() {
      if interval.isInverted() {
        return interval.lo >= lo && interval.hi <= hi
      }
      return (interval.lo >= lo || interval.hi <= hi) && !isEmpty()
    }
    if interval.isInverted() {
      return isFull() || interval.isEmpty()
    }
    return interval.lo >= lo && interval.hi <= hi
  }
  
  // InteriorContains returns true iff the interior of the interval contains p.
  // Assumes p ∈ [-π,π].
  func interiorContains(_ point: Double) -> Bool {
    var point = point
    if point == -.pi {
      point = .pi
    }
    if isInverted() {
      return point > lo || point < hi
    }
    return (point > lo && point < hi) || isFull()
  }
  
  // InteriorContainsInterval returns true iff the interior of the interval contains other.
  func interiorContains(_ interval: S1Interval) -> Bool {
    if isInverted() {
      if interval.isInverted() {
        return (interval.lo > lo && interval.hi < hi) || interval.isEmpty()
      }
      return interval.lo > lo || interval.hi < hi
    }
    if interval.isInverted() {
      return isFull() || interval.isEmpty()
    }
    return (interval.lo > lo && interval.hi < hi) || isFull()
  }
  
  // Intersects returns true iff the interval contains any points in common with interval.
  func intersects(_ interval: S1Interval) -> Bool {
    if isEmpty() || interval.isEmpty() {
      return false
    }
    if isInverted() {
      return interval.isInverted() || interval.lo <= hi || interval.hi >= lo
    }
    if interval.isInverted() {
      return interval.lo <= hi || interval.hi >= lo
    }
    return interval.lo <= hi && interval.hi >= lo
  }
  
  // InteriorIntersects returns true iff the interior of the interval contains any points in common with other, including the latter's boundary.
  func interiorIntersects(_ interval: S1Interval) -> Bool {
    if isEmpty() || interval.isEmpty() || lo == hi {
      return false
    }
    if isInverted() {
      return interval.isInverted() || interval.lo < hi || interval.hi > lo
    }
    if interval.isInverted() {
      return interval.lo < hi || interval.hi > lo
    }
    return (interval.lo < hi && interval.hi > lo) || isFull()
  }
  
  // MARK: computed members
  
  // Length returns the length of the interval.
  // The length of an empty interval is negative.
  func length() -> Double {
    var l = hi - lo
    if l >= 0.0 {
      return l
    }
    l += 2 * .pi
    if l > 0 {
      return l
    }
    return -1
  }

  // MARK: arithmetic
  
  // Compute distance from a to b in [0,2π], in a numerically stable way.
  static func positiveDistance(_ a: Double, _ b: Double) -> Double {
    let d = b - a
    if d >= 0 {
      return d
    }
    return (b + .pi) - (a - .pi)
  }

  // Union returns the smallest interval that contains both the interval and other.
  func union(_ interval: S1Interval) -> S1Interval {
    if interval.isEmpty() {
      return self
    }
    if fastContains(interval.lo) {
      if fastContains(interval.hi) {
        // Either interval ⊂ i, or i ∪ interval is the full interval.
        if contains(interval) {
          return self
        }
        return S1Interval.full
      }
      return S1Interval(lo: lo, hi: interval.hi)
    }
    if fastContains(interval.hi) {
      return S1Interval(lo: interval.lo, hi: hi)
    }
    
    // Neither endpoint of interval is in  Either i ⊂ other, or i and other are disjoint.
    if isEmpty() || interval.fastContains(lo) {
      return interval
    }
    
    // This is the only hard case where we need to find the closest pair of endpoints.
    if S1Interval.positiveDistance(interval.hi, lo) < S1Interval.positiveDistance(hi, interval.lo) {
      return S1Interval(lo: interval.lo, hi: hi)
    }
    return S1Interval(lo: lo, hi: interval.hi)
  }

  // Intersection returns the smallest interval that contains the intersection of the interval and other.
  func intersection(_ interval: S1Interval) -> S1Interval {
    if interval.isEmpty() {
      return S1Interval.empty
    }
    if fastContains(interval.lo) {
      if fastContains(interval.hi) {
        // Either other ⊂ i, or i and other intersect twice. Neither are empty.
        // In the first case we want to return i (which is shorter than other).
        // In the second case one of them is inverted, and the smallest interval
        // that covers the two disjoint pieces is the shorter of i and other.
        // We thus want to pick the shorter of i and other in both cases.
        if interval.length() < length() {
          return interval
        }
        return self
      }
      return S1Interval(lo: interval.lo, hi: hi)
    }
    if fastContains(interval.hi) {
      return S1Interval(lo: lo, hi: interval.hi)
    }
    
    // Neither endpoint of other is in  Either i ⊂ other, or i and other are disjoint.
    if interval.fastContains(lo) {
      return self
    }
    return S1Interval.empty
  }

  // AddPoint returns the interval expanded by the minimum amount necessary such
  // that it contains the given point "p" (an angle in the range [-Pi, Pi]).
  func add(_ point: Double) -> S1Interval {
    var point = point
    if fabs(point) > .pi {
      return self
    }
    if point == -.pi {
      point = .pi
    }
    if fastContains(point) {
      return self
    }
    if isEmpty() {
      return S1Interval(lo: point, hi: point)
    }
    if S1Interval.positiveDistance(point, lo) < S1Interval.positiveDistance(hi, point) {
      return S1Interval(lo: point, hi: hi)
    }
    return S1Interval(lo: lo, hi: point)
  }

  // Expanded returns an interval that has been expanded on each side by margin.
  // If margin is negative, then the function shrinks the interval on
  // each side by margin instead. The resulting interval may be empty or
  // full. Any expansion (positive or negative) of a full interval remains
  // full, and any expansion of an empty interval remains empty.
  func expanded(_ margin: Double) -> S1Interval {
    if margin >= 0 {
      if isEmpty() {
        return self
      }
      // Check whether this interval will be full after expansion, allowing
      // for a 1-bit rounding error when computing each endpoint.
      if length() + 2 * margin + 2 * S1Interval.epsilon >= 2.0 * .pi {
        return S1Interval.full
      }
    } else {
      if isFull() {
        return self
      }
      // Check whether this interval will be empty after expansion, allowing
      // for a 1-bit rounding error when computing each endpoint.
      if length() + 2 * margin - 2 * S1Interval.epsilon <= 0 {
        return S1Interval.empty
      }
    }
    let l = (lo-margin).truncatingRemainder(dividingBy: 2.0 * .pi)
    let h = (hi+margin).truncatingRemainder(dividingBy: 2.0 * .pi)
    if l <= -.pi {
      return S1Interval(lo_endpoint: .pi, hi_endpoint: h)
    }
    return S1Interval(lo_endpoint: l, hi_endpoint: h)
  }

}
