//
//  S2Metric.swift
//  Sphere2
//

import Foundation

// package s2
// import math

// This file implements functions for various S2 measurements.
// A Metric is a measure for cells.
struct Metric {
  
  // Dim is either 1 or 2, for a 1D or 2D metric respectively.
  let dim: Int
  // Deriv is the scaling factor for the metric.
  let deriv: Double

  // MARK: inits / factory 

  // default constructur is utomatic
  
  // Defined metrics.
  // We only support the quadratic projection.
  static let minWidth = Metric(dim: 1, deriv: 2 * sqrt(2.0) / 3)
  static let maxWidth = Metric(dim: 1, deriv: 1.704897179199218452)

  static let minArea = Metric(dim: 2, deriv: 8 * sqrt(2.0) / 9)
  static let avgArea = Metric(dim: 2, deriv: 4 * .pi / 6)
  static let maxArea = Metric(dim: 2, deriv: 2.635799256963161491)

  // TODO: more metrics, as needed
  // TODO: port GetValue, GetClosestLevel

  // Value returns the value of the metric at the given level.
  func value(_ level: Int) -> Double {
    return ldexp(deriv, -dim * level)
  }

  // MinLevel returns the minimum level such that the metric is at most
  // the given value, or maxLevel (30) if there is no such level.
  func minLevel(_ val: Double) -> Int {
    if val < 0 {
      return CellId.maxLevel
    }
    
    var level = -(Int(logb(val / deriv)) >> (dim - 1))
    if level > CellId.maxLevel {
      level = CellId.maxLevel
    }
    if level < 0 {
      level = 0
    }
    return level
  }

  // MaxLevel returns the maximum level such that the metric is at least
  // the given value, or zero if there is no such level.
  func maxLevel(_ val: Double) -> Int {
    if val <= 0 {
      return CellId.maxLevel
    }
    
    var level = Int(logb(deriv / val)) >> (dim - 1)
    if level > CellId.maxLevel {
      level = CellId.maxLevel
    }
    if level < 0 {
      level = 0
    }
    return level
  }

}
