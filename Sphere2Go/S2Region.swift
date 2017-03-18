//
//  S2Region.swift
//  Sphere2
//

import Foundation

// package s2

// A Region represents a two-dimensional region on the unit sphere.
//
// The purpose of this interface is to allow complex regions to be
// approximated as simpler regions. The interface is restricted to methods
// that are useful for computing approximations.
protocol S2Region  {
  // CapBound returns a bounding spherical cap. This is not guaranteed to be exact.
  func capBound() -> S2Cap
  
  // RectBound returns a bounding latitude-longitude rectangle that contains
  // the region. The bounds are not guaranteed to be tight.
  func rectBound() -> S2Rect
  
  // ContainsCell reports whether the region completely contains the given region.
  // It returns false if containment could not be determined.
  func contains(_ cell: Cell) -> Bool
  
  // IntersectsCell reports whether the region intersects the given cell or
  // if intersection could not be determined. It returns false if the region
  // does not intersect.
  func intersects(_ cell: Cell) -> Bool
}

// Enforce interface satisfaction.
//extension Cell: S2Region {}
//extension CellUnion: S2Region {}
//extension S2Cap: S2Region {}
//extension S2Rect: S2Region {}
//extension S2Loop: S2Region {}
//extension S2Polygon: S2Region {}
