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
    
    func testAttemptingToSetProgressTrackToLessThanZeroMakesItReset() {
        svgPlayButton.progressStrokeEnd = 0.75
        svgPlayButton.progressStrokeEnd = -0.25
        XCTAssertTrue(svgPlayButton.progressStrokeEnd == 0)
    }
    
    func testAttemptingToSetProgressTrackToGreaterThanZeroMakesItReset() {
        svgPlayButton.progressStrokeEnd = 0.75
        svgPlayButton.progressStrokeEnd = 1.25
        XCTAssertTrue(svgPlayButton.progressStrokeEnd == 0)
    }
}
