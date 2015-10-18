import UIKit
import XCTest
import SVGPlayButton

class Tests: XCTestCase {
    
    var svgPlayButton: SVGPlayButton!

    override func setUp() {
        super.setUp()
        svgPlayButton = SVGPlayButton(frame: CGRectMake(0, 0, 25, 25))
    }
    
    override func tearDown() {
        super.tearDown()
        svgPlayButton = nil
    }

    func testItsNotPlayingByDefaut() {
        XCTAssertFalse(svgPlayButton.playing)
    }
    
    func testProgressTrackIsZeroByDefault() {
        XCTAssertTrue(svgPlayButton.progressStrokeEnd == 0)
    }
    
    func testItResetsTheProgressTrack() {
        svgPlayButton.progressStrokeEnd = 0.75
        svgPlayButton.resetProgressLayer()
        XCTAssertTrue(svgPlayButton.progressStrokeEnd == 0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
