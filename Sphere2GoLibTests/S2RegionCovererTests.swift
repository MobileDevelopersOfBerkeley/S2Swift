//
//  S2RegionCovererTests.swift
//  Sphere2
//

import XCTest


class S2RegionCovererTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    CellId.setup()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testRandomCells() {
    let rc = RegionCoverer(minLevel: 0, maxLevel: 30, levelMod: 1, maxCells: 1)
    // Test random cell ids at all levels.
    for _ in 0..<10000 {
      var id = CellId(id: randomUInt64())
      while !id.isValid() {
        id = CellId(id: randomUInt64())
      }
      let region = Cell(id: id) as S2Region
      let covering = rc.covering(region: region)
      XCTAssertEqual(covering.count, 1)
      XCTAssertEqual(covering[0], id, "\(covering[0]) \(id)")
    }
  }

  func testRandomCaps() {
    for _ in 0..<100 {
      let l1 = Int(arc4random() % UInt32(CellId.maxLevel + 1))
      let l2 = Int(arc4random() % UInt32(CellId.maxLevel + 1))
      let rc = RegionCoverer(minLevel: min(l1, l2), maxLevel: max(l1, l2), levelMod: Int(arc4random() % 3 + 1), maxCells: Int(skewedInt(maxLog: 10)))
      //
      let maxArea = min(4.0 * Double.pi, Double(3 * rc.maxCells + 1) * Metric.avgArea.value(rc.minLevel))
      let r = randomCap(minArea: 0.1 * Metric.avgArea.value(rc.maxLevel), maxArea: maxArea) as S2Region
      let covering = rc.covering(region: r)
      checkCovering(rc: rc, r: r, covering: covering, interior: false)
      let interior = rc.interiorCovering(region: r)
      checkCovering(rc: rc, r: r, covering: interior, interior: true)
      // Check that Covering is deterministic.
      let covering2 = rc.covering(region: r)
      XCTAssertEqual(covering, covering2)
      // Also check Denormalize. The denormalized covering
      // may still be different and smaller than "covering" because
      // s2.RegionCoverer does not guarantee that it will not output all four
      // children of the same parent.
      covering.denormalize(minLevel: rc.minLevel, levelMod: rc.levelMod)
      checkCovering(rc: rc, r: r, covering: covering, interior: false)
    }
  }
  
//  func testPolygons() {
//    let coords = [(37.5, 122.5), (37.5, 122), (37, 122), (37, 122.5)]
//    let latLngs = coords.map { LatLng(latDegrees: $0, lngDegrees: $1) }
//    let points = latLngs.map { S2Point(latLng: $0) }
//    let loop = S2Loop(points: points)
//    let poly = S2Polygon(loops: [loop])
//    for _ in 0..<100 {
//      let l1 = Int(arc4random() % UInt32(CellId.maxLevel + 1))
//      let l2 = Int(arc4random() % UInt32(CellId.maxLevel + 1))
//      let rc = RegionCoverer(minLevel: min(l1, l2), maxLevel: max(l1, l2), levelMod: Int(arc4random() % 3 + 1), maxCells: Int(skewedInt(maxLog: 10)))
//      //
//      let r = poly
//      let covering = rc.covering(region: r)
//      checkCovering(rc: rc, r: r, covering: covering, interior: false)
//      let interior = rc.interiorCovering(region: r)
//      checkCovering(rc: rc, r: r, covering: interior, interior: true)
//      // Check that Covering is deterministic.
//      let covering2 = rc.covering(region: r)
//      XCTAssertEqual(covering, covering2)
//      // Also check Denormalize. The denormalized covering
//      // may still be different and smaller than "covering" because
//      // s2.RegionCoverer does not guarantee that it will not output all four
//      // children of the same parent.
//      covering.denormalize(minLevel: rc.minLevel, levelMod: rc.levelMod)
//      checkCovering(rc: rc, r: r, covering: covering, interior: false)
//    }
//  }
  
  // checkCovering reports whether covering is a valid cover for the region.
  func checkCovering(rc: RegionCoverer, r: S2Region, covering: CellUnion, interior: Bool) {
    // Keep track of how many cells have the same rc.MinLevel ancestor.
    var minLevelCells = [CellId: Int]()
    let tempCover = CellUnion(ids: [])
    for i in 0..<covering.count {
      let ci = covering[i]
      let level = ci.level()
      XCTAssert(level >= rc.minLevel)
      XCTAssert(level <= rc.maxLevel)
      XCTAssertEqual((level - rc.minLevel) % rc.levelMod, 0)
      tempCover.add(ci)
      let i = ci.parent(rc.minLevel)
      minLevelCells[i] = (minLevelCells[i] ?? 0) + 1
    }
    if covering.count > rc.maxCells {
      // If the covering has more than the requested number of cells, then check
      // that the cell count cannot be reduced by using the parent of some cell.
      for count in minLevelCells.values {
        XCTAssert(count <= 1)
      }
    }
    if interior {
      for i in 0..<covering.count {
        let ci = covering[i]
        XCTAssertTrue(r.contains(Cell(id: ci)))
      }
    } else {
      tempCover.normalize()
      checkCoveringTight(r: r, cover: tempCover, checkTight: true, id: CellId(id: 0), rc: rc)
    }
  }

  // checkCoveringTight checks that "cover" completely covers the given region.
  // If "checkTight" is true, also checks that it does not contain any cells that
  // do not intersect the given region. ("id" is only used internally.)
  func checkCoveringTight(r: S2Region, cover: CellUnion, checkTight: Bool, id: CellId, rc: RegionCoverer) {
    if !id.isValid() {
      for f in 0..<6 {
        checkCoveringTight(r: r, cover: cover, checkTight: checkTight, id: CellId(face: f), rc: rc)
      }
      return
    }
    if !r.intersects(Cell(id: id)) {
      // If region does not intersect id, then neither should the covering.
      XCTAssertFalse(cover.intersects(id) && checkTight)
    } else if !cover.contains(id) {
      // The region may intersect id, but we can't assert that the covering
      // intersects id because we may discover that the region does not actually
      // intersect upon further subdivision.  (IntersectsCell is not exact.)
      XCTAssertFalse(r.contains(Cell(id: id)))
      XCTAssertFalse(id.isLeaf())
      for ci in id.children(level: nil) {
        checkCoveringTight(r: r, cover: cover, checkTight: checkTight, id: ci, rc: rc)
      }
//      let end = id.childEnd()
//      var ci = id.childBegin()
//      print("LEVEL", ci.level())
//      while ci != end {
//        checkCoveringTight(r: r, cover: cover, checkTight: checkTight, id: ci, rc: rc)
//        ci = ci.next()
//      }
    }
  }

}
