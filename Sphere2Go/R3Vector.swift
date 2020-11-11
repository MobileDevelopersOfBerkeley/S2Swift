//
//  R3Vector.swift
//  Sphere2
//

import Foundation

// package r3
// import fmt, math, s1

// R3Vector represents a point in ℝ³.
struct R3Vector: Equatable, CustomStringConvertible, Hashable {
  
  static let epsilon = 1e-14

  //
  let x: Double
  let y: Double
  let z: Double
    
  // MARK: inits

  init(x: Double, y: Double, z: Double) {
    self.x = x
    self.y = y
    self.z = z
  }

  // MARK: protocols

  static func ==(lhs: R3Vector, rhs: R3Vector) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
  }

  var description: String {
    return "(\(x), \(y), \(z))"
  }

  // MARK: tests
  
  // ApproxEqual reports whether v and other are equal within a small epsilon.
  func approxEquals(_ vector: R3Vector) -> Bool {
    return fabs(x-vector.x) < R3Vector.epsilon && fabs(y-vector.y) < R3Vector.epsilon && fabs(z-vector.z) < R3Vector.epsilon
  }

  // IsUnit returns whether this vector is of approximately unit length.
  func isUnit() -> Bool {
    return fabs(norm2()-1) <= R3Vector.epsilon
  }
  
  // MARK: computed members
  
  // Norm returns the vector's norm.
  func norm() -> Double {
    return sqrt(dot(self))
  }

  // Norm2 returns the square of the norm.
  func norm2() -> Double {
    return dot(self)
  }

  // Normalize returns a unit vector in the same direction as 
  func normalize() -> R3Vector {
    if x == 0.0 && y == 0.0 && z == 0.0 {
      return self
    }
    return mul(1.0 / norm())
  }

  // Abs returns the vector with nonnegative components.
  func abs() -> R3Vector {
    return R3Vector(x: fabs(x), y: fabs(y), z: fabs(z))
  }

  // Ortho returns a unit vector that is orthogonal to 
  // Ortho(-v) = -Ortho(v) for all 
  func ortho() -> R3Vector {
    // Grow a component other than the largest in v, to guarantee that they aren't
    // parallel (which would make the cross product zero).
    let vector: R3Vector
    if fabs(x) > fabs(y) {
      vector = R3Vector(x: 0.012, y: 1.0, z: 0.00457)
    } else {
      vector = R3Vector(x: 1.0, y: 0.0053, z: 0.00457)
    }
    return cross(vector).normalize()
  }
  
  var s2: S2Point {
    return S2Point(raw: self)
  }
  
  // MARK: arithmetic
  
  // Add returns the standard vector sum of v and other.
  func add(_ vector: R3Vector) -> R3Vector {
    return R3Vector(x: x + vector.x, y: y + vector.y, z: z + vector.z)
  }

  // Sub returns the standard vector difference of v and other.
  func sub(_ vector: R3Vector) -> R3Vector {
    return R3Vector(x: x - vector.x, y: y - vector.y, z: z - vector.z)
  }

  // Mul returns the standard scalar product of v and m.
  func mul(_ m: Double) -> R3Vector {
    return R3Vector(x: m * x, y: m * y, z: m * z)
  }

  // Dot returns the standard dot product of v and other.
  func dot(_ vector: R3Vector) -> Double {
    return x*vector.x + y*vector.y + z*vector.z
  }

  // Cross returns the standard cross product of v and other.
  func cross(_ vector: R3Vector) -> R3Vector {
    return R3Vector(x: y*vector.z - z*vector.y, y: z*vector.x - x*vector.z, z: x*vector.y - y*vector.x)
  }

  // Distance returns the Euclidean distance between v and other.
  func distance(_ vector: R3Vector) -> Double {
    return sub(vector).norm()
  }

  // Angle returns the angle between v and vector.
  func angle(_ vector: R3Vector) -> Double {
    return atan2(cross(vector).norm(), dot(vector))
  }

}
