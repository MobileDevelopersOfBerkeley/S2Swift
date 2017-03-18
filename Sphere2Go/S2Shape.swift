//
//  S2ShapeIndex.swift
//  Sphere2
//

import Foundation

// package s2


// dimension defines the types of geometry dimensions that a Shape supports.
enum Dimension: Int {
  case pointGeometry
  case polylineGeometry
  case polygonGeometry
}

// Shape defines an interface for any s2 type that needs to be indexable.
protocol Shape {
  
  // NumEdges returns the number of edges in this shape.
  func numEdges() -> Int
  
  // Edge returns endpoints for the given edge index.
  func edge(_ i: Int) -> (S2Point, S2Point)
  
  // HasInterior returns true if this shape has an interior.
  // i.e. the Shape consists of one or more closed non-intersecting loops.
  func hasInterior() -> Bool
  
  // ContainsOrigin returns true if this shape contains s2.Origin.
  // Shapes that do not have an interior will return false.
  func containsOrigin() -> Bool
}

//func ==(lhs: Shape, rhs: Shape) -> Bool {
//    return lhs.numEdges() == rhs.numEdges()
//}

// CellRelation describes the possible relationships between a target cell
// and the cells of the ShapeIndex. If the target is an index cell or is
// contained by an index cell, it is Indexed. If the target is subdivided
// into one or more index cells, it is Subdivided. Otherwise it is Disjoint.
enum CellRelation: Int {
  // The possible CellRelations for a ShapeIndex.
  case indexed = 0
  case subdivided = 1
  case disjoint = 2
}

// cellPadding defines the total error when clipping an edge which comes
// from two sources:
// (1) Clipping the original spherical edge to a cube face (the face edge).
//     The maximum error in this step is faceClipErrorUVCoord.
// (2) Clipping the face edge to the u- or v-coordinate of a cell boundary.
//     The maximum error in this step is edgeClipErrorUVCoord.
// Finally, since we encounter the same errors when clipping query edges, we
// double the total error so that we only need to pad edges during indexing
// and not at query time.
let cellPadding = 2.0 * (faceClipErrorUVCoord + edgeClipErrorUVCoord)


// ShapeIndex indexes a set of Shapes, where a Shape is some collection of
// edges. A shape can be as simple as a single edge, or as complex as a set of loops.
// For Shapes that have interiors, the index makes it very fast to determine which
// Shape(s) that contain a given point or region.
class ShapeIndex {
  // shapes contains all the shapes in this index, accessible by their shape id.
  // Removed shapes are replaced by nil.
  //
  // TODO(roberts): Is there a better storage structure to use? C++ uses a btree
  // deep down for the index. There do appear to be a number of Go BTree
  // implementations available that may be suitable. Further investigation
  // is needed before selecting an appropriate option.
  //
  // The slice is an interim storage solution to get the index up and usable.
  var shapes = [Shape]()
  
  let maxEdgesPerCell: Int
  
  init() {
    maxEdgesPerCell = 10
  }

  // Add adds the given shape to the index and assign a unique id to the shape.
  // Shape ids are assigned sequentially starting from 0 in the order shapes are added.
  func add(_ shape: Shape) {
    shapes.append(shape)
  }

  // Len reports the number of Shapes in this index.
  var count: Int {
    return shapes.count
  }

  // At returns the shape with the given index. If the given index is not valid, nil is returned.
  func at(_ i: Int) -> Shape {
    // TODO(roberts): This blindly assumes that no Shapes have been removed and
    // that the slice has no holes in it. As this gets implemented, change this
    // to be smarter and safer about verifying existence before returning it.
    return shapes[i]
  }

  // Reset clears the contents of the index and resets it to its original state.
  // Any options specified via Init are preserved.
  func reset() {
    shapes = []
  }

}
