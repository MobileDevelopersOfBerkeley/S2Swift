//
//  R1Interval.swift
//  Sphere2
//

import Foundation

// package r1
// import fmt, math

// R1Interval represents a closed interval on ℝ.
// Zero-length intervals (where Lo == Hi) represent single points.
// If Lo > Hi then the interval is empty.
// The major differences from the C++ version are:
//   - a few other miscellaneous operations
struct R1Interval: Equatable, CustomStringConvertible {
  
  //
  let lo: Double
  let hi: Double
  
  // epsilon is a small number that represents a reasonable level of noise between two
  // values that can be considered to be equal.
  static let epsilon = 1e-14
  
  // MARK: inits / factory
  
  init(lo: Double, hi: Double) {
    self.lo = lo
    self.hi = hi
  }
  
  init(point: Double)  {
    self.lo = point
    self.hi = point
  }
  
  static let empty = R1Interval(lo:1.0, hi: 0.0)
  
  // MARK: protocols
  
  var description: String {
    let l = String(format: "%.7f", lo)
    let h = String(format: "%.7f", hi)
    return "[\(l), \(h)]"
  }

  // MARK: tests 
  
  // IsEmpty reports whether the interval is empty.
  func isEmpty() -> Bool {
    return lo > hi
  }
  
  // Equal returns true iff the interval contains the same points as other.
  func equals(_ interval: R1Interval) -> Bool {
    return lo == interval.lo && hi == interval.hi || isEmpty() && interval.isEmpty()
  }
  
  // Contains returns true iff the interval contains p.
  func contains(_ point: Double) -> Bool {
    return lo <= point && point <= hi
  }
  
  // ContainsInterval returns true iff the interval contains other.
  func contains(_ interval: R1Interval) -> Bool {
    if interval.isEmpty() {
      return true
    }
    return lo <= interval.lo && interval.hi <= hi
  }
  
  // InteriorContains returns true iff the the interval strictly contains p.
  func interiorContains(_ point: Double) -> Bool {
    return lo < point && point < hi
  }
  
  // InteriorContainsInterval returns true iff the interval strictly contains other.
  func interiorContains(_ interval: R1Interval) -> Bool {
    if interval.isEmpty() {
      return true
    }
    return lo < interval.lo && interval.hi < hi
  }
  
  // Intersects returns true iff the interval contains any points in common with other.
  func intersects(_ interval: R1Interval) -> Bool {
    if lo <= interval.lo {
      return interval.lo <= hi && interval.lo <= interval.hi // interval.lo ∈ i and interval is not empty
    }
    return lo <= interval.hi && lo <= hi // lo ∈ interval and i is not empty
  }
  
  // InteriorIntersects returns true iff the interior of the interval contains any points in common with other, including the latter's boundary.
  func interiorIntersects(_ interval: R1Interval) -> Bool {
    return interval.lo < hi && lo < interval.hi && lo < hi && interval.lo <= hi
  }
  
  // Intersection returns the interval containing all points common to i and j.
  func intersection(_ interval: R1Interval) -> R1Interval {
    // Empty intervals do not need to be special-cased.
    return R1Interval(lo: max(lo, interval.lo), hi: min(hi, interval.hi))
  }
  
  // ApproxEqual reports whether the interval can be transformed into the
  // given interval by moving each endpoint a small distance.
  // The empty interval is considered to be positioned arbitrarily on the
  // real line, so any interval with a small enough length will match
  // the empty interval.
  func approxEquals(_ interval: R1Interval) -> Bool {
    if isEmpty() {
      return interval.length() <= 2 * R1Interval.epsilon
    }
    if interval.isEmpty() {
      return length() <= 2 * R1Interval.epsilon
    }
    return fabs(interval.lo-lo) <= R1Interval.epsilon && fabs(interval.hi-hi) <= R1Interval.epsilon
  }
  
  // MARK: computed members
  
  // Center returns the midpoint of the interval.
  // It is undefined for empty intervals.
  func center() -> Double {
    return 0.5 * (lo + hi)
  }
  
  // Length returns the length of the interval.
  // The length of an empty interval is negative.
  func length() -> Double {
    return hi - lo
  }
  
  // MARK: arithmetic
  
  // AddPoint returns the interval expanded so that it contains the given point.
  func add(_ point: Double) -> R1Interval {
    if isEmpty() {
      return R1Interval(lo: point, hi: point)
    }
    if point < lo {
      return R1Interval(lo: point, hi: hi)
    }
    if point > hi {
      return R1Interval(lo: lo, hi: point)
    }
    return self
  }
  
  // ClampPoint returns the closest point in the interval to the given point "p".
  // The interval must be non-empty.
  func clamp(_ point: Double) -> Double {
    return max(lo, min(hi, point))
  }
  
  // Expanded returns an interval that has been expanded on each side by margin.
  // If margin is negative, then the function shrinks the interval on
  // each side by margin instead. The resulting interval may be empty. Any
  // expansion of an empty interval remains empty.
  func expanded(_ margin: Double) -> R1Interval {
    if isEmpty() {
      return self
    }
    return R1Interval(lo: lo - margin, hi: hi + margin)
  }
  
  // Union returns the smallest interval that contains this interval and the given interval.
  func union(_ interval: R1Interval) -> R1Interval {
    if isEmpty() {
      return interval
    }
    if interval.isEmpty() {
      return self
    }
    return R1Interval(lo: min(lo, interval.lo), hi: max(hi, interval.hi))
  }
  
}

func ==(lhs: R1Interval, rhs: R1Interval) -> Bool {
  return lhs.lo == rhs.lo && lhs.hi == rhs.hi || (lhs.isEmpty() && rhs.isEmpty())
}
