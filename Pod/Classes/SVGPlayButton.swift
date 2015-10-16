import UIKit

private let salmonColor = UIColor(
    red: 225.0 / 255.0,
    green: 60.0 / 255.0,
    blue: 60.0 / 255.0,
    alpha: 1.0
)

private let lightGray = UIColor(
    red: 223.0 / 255.0,
    green: 223.0 / 255.0,
    blue: 224.0 / 250.0,
    alpha: 1
)

private let darkGray = UIColor(
    red: 147.0 / 255.0,
    green: 149.0 / 255.0,
    blue: 152.0 / 250.0,
    alpha: 1
)

private let kDefaultProgressColor       = salmonColor
private let kDefaultProgressTrackColor  = lightGray
private let kDefaultPlayColor           = darkGray
private let kDefaultPauseColor          = darkGray

private let kInnerRadiusScaleFactor = CGFloat(0.05)

@IBDesignable public class SVGPlayButton: UIButton {
    
    private var playing: Bool = false {
        didSet {
            if playing {
                presentForPlaying()
            } else {
                presentForPaused()
            }
        }
    }
    
    public var isPlaying: Bool {
        get {
            return self.playing
        }
    }
    
    private var progressTrackShapeLayer: CAShapeLayer = CAShapeLayer()
    
    private var progressShapeLayer: CAShapeLayer = CAShapeLayer()
    
    private var playShapeLayer: CAShapeLayer = CAShapeLayer()
    
    private var pauseShapeLayerLeft: CAShapeLayer = CAShapeLayer()
    
    private var pauseShapeLayerRight: CAShapeLayer = CAShapeLayer()
    
    public var progressColor: UIColor = kDefaultProgressColor
    
    public var progressTrackColor: UIColor = lightGray
    
    public var playColor: UIColor = darkGray
    
    public var pauseColor: UIColor = darkGray
    
    //
    //  If actions are not disabled, the progress layer's strokeEnd update will animate by default. Because we update this so many times a second, like 60
    //  times a second, there will be a noticeable lag in the view's representation of the path w/r/t where the current strokeEnd actually 'is'. Turning off animations
    //  solves this b/c the path updates immediately, and since we're updating at such a high number of times per second, it looks smooth when one's looking watching the view.
    //
    public var progressStrokeEnd: CGFloat = 0 {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.progressShapeLayer.strokeEnd = progressStrokeEnd
            CATransaction.commit()
        }
    }
    
    public var willPlay: (() -> ())?
    
    public var willPause: (() -> ())?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    private func sharedInit() {
        self.addTarget(self, action: "touchUpInsideHandler", forControlEvents: UIControlEvents.TouchUpInside)
    }

    override public func drawRect(rect: CGRect) {

        //
        // Pause
        //
        
        let center: CGPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        let pauseLineHeight = CGRectGetHeight(rect) * 0.357
        let pauseLineWidth  = CGRectGetWidth(rect) * 0.0714
        
        enum PauseLinePosition {
            case Left
            case Right
        }
        
        func pauseLine(position: PauseLinePosition) -> UIBezierPath {
            
            let pauseLineRectY = (bounds.height/2) - (pauseLineHeight * 0.5)
            var pauseLineRect = CGRectMake(0, pauseLineRectY, pauseLineWidth, pauseLineHeight)
            
            if position == .Left {
                let pauseLineRectX = (bounds.width / 2) - (pauseLineWidth * 0.5) - (pauseLineWidth * 1.25)
                pauseLineRect.origin.x = pauseLineRectX
            }
            
            if position == .Right {
                let pauseLineRectX = (bounds.width / 2) - (pauseLineWidth * 0.5) + (pauseLineWidth * 1.25)
                pauseLineRect.origin.x = pauseLineRectX
            }
            
            let pauseLinePath = UIBezierPath(roundedRect: pauseLineRect, cornerRadius: (pauseLineWidth * 0.45))
            
            return pauseLinePath
        }
        
        pauseShapeLayerLeft.path = pauseLine(.Left).CGPath
        pauseShapeLayerLeft.fillColor = pauseColor.CGColor
        pauseShapeLayerLeft.hidden = self.playing ? false : true
        self.layer.addSublayer(pauseShapeLayerLeft)
        
        pauseShapeLayerRight.path = pauseLine(.Right).CGPath
        pauseShapeLayerRight.fillColor = pauseColor.CGColor
        pauseShapeLayerRight.hidden = self.playing ? false : true
        self.layer.addSublayer(pauseShapeLayerRight)
        
        //
        // Play
        //
        
        let midY = CGRectGetMidY(rect)
        let playLeftX = CGRectGetWidth(rect) * 0.4107
        
        let playPath = UIBezierPath()
        playPath.lineJoinStyle = CGLineJoin.Round
        playPath.moveToPoint(CGPointMake(playLeftX, midY))
        playPath.addLineToPoint(CGPointMake(playLeftX, (midY - CGRectGetHeight(rect) * 0.17)))
        playPath.addLineToPoint(CGPointMake(playLeftX + (CGRectGetWidth(rect) * 0.2322), midY))
        playPath.addLineToPoint(CGPointMake(playLeftX, (midY + CGRectGetHeight(rect) * 0.17)))
        playPath.addLineToPoint(CGPointMake(playLeftX, midY))
        
        playShapeLayer.path = playPath.CGPath
        playShapeLayer.strokeColor = playColor.CGColor
        playShapeLayer.fillColor = playColor.CGColor
        playShapeLayer.hidden = self.playing ? true : false
        self.layer.addSublayer(playShapeLayer)
        
        // helper
        func d2R(degrees: CGFloat) -> CGFloat {
            return degrees * 0.0174532925 // 1 degree ~ 0.0174532925 radians
        }
        
        let arcWidth = (CGRectGetWidth(rect) * kInnerRadiusScaleFactor) / 2
        let radius = (CGRectGetMidY(rect) - arcWidth/2)
        
        //
        //  Progress 'track'
        //
        //  This never updates once the view's been drawn so we don't need to add it to a layer BUT, it was noticed that drawing the path without one resulted
        //  in noticeably lower fidelity when observed on the screen, so we'll use a layer anyway.
        //
        //  If you're interested in seeing what I'm talking about, use the code below:
        //
        
        /*
        let progressTrackPath = UIBezierPath(arcCenter: CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)), radius: radius, startAngle: degrees2Radians(270), endAngle: degrees2Radians(269.99), clockwise: true)
        progressTrackPath.lineWidth = arcWidth
        kDefaultProgressTrackColor.setStroke()
        progressTrackPath.stroke()
        */
        
        func progressArc() -> CGPath {
            return UIBezierPath(arcCenter: CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)), radius: radius, startAngle: d2R(270), endAngle: d2R(269.99), clockwise: true).CGPath
        }
        
        progressTrackShapeLayer.path = progressArc()
        progressTrackShapeLayer.strokeColor = progressTrackColor.CGColor
        progressTrackShapeLayer.fillColor = UIColor.clearColor().CGColor
        progressTrackShapeLayer.lineWidth = arcWidth
        self.layer.addSublayer(progressTrackShapeLayer)
        
        //
        // Progress
        //
        
        progressShapeLayer.path = progressArc()
        progressShapeLayer.strokeColor = progressColor.CGColor
        progressShapeLayer.fillColor = UIColor.clearColor().CGColor
        progressShapeLayer.lineWidth = arcWidth
        progressShapeLayer.strokeStart = 0
        progressShapeLayer.strokeEnd = self.progressStrokeEnd
        self.layer.addSublayer(progressShapeLayer)
        
    }
    
    public func resetProgressLayer() {
        self.progressStrokeEnd = 0
    }
    
    func touchUpInsideHandler() {
        if playing {
            if let willPause = self.willPause {
                willPause()
            }
            playing = false
        } else {
            if let willPlay = self.willPlay {
                willPlay()
            }
            playing = true
        }
    }
    
    private func presentForPlaying() {
        playShapeLayer.hidden = true
        pauseShapeLayerLeft.hidden = false
        pauseShapeLayerRight.hidden = false
    }
    
    private func presentForPaused() {
        playShapeLayer.hidden = false
        pauseShapeLayerLeft.hidden = true
        pauseShapeLayerRight.hidden = true
    }
    
}
