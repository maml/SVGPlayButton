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

private let kInnerRadiusScaleFactor = CGFloat(0.05)

@IBDesignable open class SVGPlayButton: UIButton {
    
    @IBInspectable open var playing: Bool = false {
        didSet {
            if playing {
                presentForPlaying()
            } else {
                presentForPaused()
            }
        }
    }
    
    fileprivate var progressTrackShapeLayer: CAShapeLayer = CAShapeLayer()
    
    fileprivate var progressShapeLayer: CAShapeLayer = CAShapeLayer()
    
    fileprivate var playShapeLayer: CAShapeLayer = CAShapeLayer()
    
    fileprivate var pauseShapeLayerLeft: CAShapeLayer = CAShapeLayer()
    
    fileprivate var pauseShapeLayerRight: CAShapeLayer = CAShapeLayer()
    
    @IBInspectable open var progressColor: UIColor = salmonColor
    
    @IBInspectable open var progressTrackColor: UIColor = lightGray
    
    @IBInspectable open var playColor: UIColor = darkGray
    
    @IBInspectable open var pauseColor: UIColor = darkGray
    
    //
    //  If actions are not disabled, the progress layer's strokeEnd update will animate by default. Because we update this so many times a second, like 60
    //  times a second, there will be a noticeable lag in the view's representation of the path w/r/t where the current strokeEnd actually 'is'. Turning off animations
    //  solves this b/c the path updates immediately, and since we're updating at such a high number of times per second, it looks smooth when one's looking watching the view.
    //
    @IBInspectable open var progressStrokeEnd: CGFloat = 0 {
        didSet {
            if progressStrokeEnd < 0 || progressStrokeEnd > 1 {
                self.resetProgressLayer()
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.progressShapeLayer.strokeEnd = progressStrokeEnd
            CATransaction.commit()
        }
    }
    
    open var willPlay: (() -> ())?
    
    open var willPause: (() -> ())?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    fileprivate func sharedInit() {
        self.addTarget(self, action: #selector(SVGPlayButton.touchUpInsideHandler), for: UIControlEvents.touchUpInside)
    }
    
    override open func draw(_ rect: CGRect) {
        
        //
        // Pause
        //
        
        let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
        let pauseLineHeight = rect.height * 0.357
        let pauseLineWidth  = rect.width * 0.0714
        
        enum PauseLinePosition {
            case left
            case right
        }
        
        func pauseLine(_ position: PauseLinePosition) -> UIBezierPath {
            
            let pauseLineRectY = (bounds.height/2) - (pauseLineHeight * 0.5)
            var pauseLineRect = CGRect(x: 0, y: pauseLineRectY, width: pauseLineWidth, height: pauseLineHeight)
            
            if position == .left {
                let pauseLineRectX = (bounds.width / 2) - (pauseLineWidth * 0.5) - (pauseLineWidth * 1.25)
                pauseLineRect.origin.x = pauseLineRectX
            }
            
            if position == .right {
                let pauseLineRectX = (bounds.width / 2) - (pauseLineWidth * 0.5) + (pauseLineWidth * 1.25)
                pauseLineRect.origin.x = pauseLineRectX
            }
            
            let pauseLinePath = UIBezierPath(roundedRect: pauseLineRect, cornerRadius: (pauseLineWidth * 0.45))
            
            return pauseLinePath
        }
        
        pauseShapeLayerLeft.path = pauseLine(.left).cgPath
        pauseShapeLayerLeft.fillColor = pauseColor.cgColor
        pauseShapeLayerLeft.isHidden = self.playing ? false : true
        self.layer.addSublayer(pauseShapeLayerLeft)
        
        pauseShapeLayerRight.path = pauseLine(.right).cgPath
        pauseShapeLayerRight.fillColor = pauseColor.cgColor
        pauseShapeLayerRight.isHidden = self.playing ? false : true
        self.layer.addSublayer(pauseShapeLayerRight)
        
        //
        // Play
        //
        
        let midY = rect.midY
        let playLeftX = rect.width * 0.4107
        
        let playPath = UIBezierPath()
        playPath.lineJoinStyle = CGLineJoin.round
        playPath.move(to: CGPoint(x: playLeftX, y: midY))
        playPath.addLine(to: CGPoint(x: playLeftX, y: (midY - rect.height * 0.17)))
        playPath.addLine(to: CGPoint(x: playLeftX + (rect.width * 0.2322), y: midY))
        playPath.addLine(to: CGPoint(x: playLeftX, y: (midY + rect.height * 0.17)))
        playPath.addLine(to: CGPoint(x: playLeftX, y: midY))
        
        playShapeLayer.path = playPath.cgPath
        playShapeLayer.strokeColor = playColor.cgColor
        playShapeLayer.fillColor = playColor.cgColor
        playShapeLayer.isHidden = self.playing ? true : false
        self.layer.addSublayer(playShapeLayer)
        
        // helper
        func d2R(_ degrees: CGFloat) -> CGFloat {
            return degrees * 0.0174532925 // 1 degree ~ 0.0174532925 radians
        }
        
        let arcWidth = (rect.width * kInnerRadiusScaleFactor)
        let radius = (rect.midY - arcWidth/2)
        
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
            return UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: d2R(270), endAngle: d2R(269.99), clockwise: true).cgPath
        }
        
        progressTrackShapeLayer.path = progressArc()
        progressTrackShapeLayer.strokeColor = progressTrackColor.cgColor
        progressTrackShapeLayer.fillColor = UIColor.clear.cgColor
        progressTrackShapeLayer.lineWidth = arcWidth
        self.layer.addSublayer(progressTrackShapeLayer)
        
        //
        // Progress
        //
        
        progressShapeLayer.path = progressArc()
        progressShapeLayer.strokeColor = progressColor.cgColor
        progressShapeLayer.fillColor = UIColor.clear.cgColor
        progressShapeLayer.lineWidth = arcWidth
        progressShapeLayer.strokeStart = 0
        progressShapeLayer.strokeEnd = self.progressStrokeEnd
        self.layer.addSublayer(progressShapeLayer)
        
    }
    
    open func resetProgressLayer() {
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
    
    fileprivate func presentForPlaying() {
        playShapeLayer.isHidden = true
        pauseShapeLayerLeft.isHidden = false
        pauseShapeLayerRight.isHidden = false
        self.animate()
    }
    
    fileprivate func presentForPaused() {
        playShapeLayer.isHidden = false
        pauseShapeLayerLeft.isHidden = true
        pauseShapeLayerRight.isHidden = true
        self.animate()
    }
    
    fileprivate func animate() {
        let t1 = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.transform = t1
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.225, initialSpringVelocity: 0.7, options: .beginFromCurrentState, animations: { () -> Void in
            let t2 = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.transform = t2
            }, completion: { (b) -> Void in
                //
        })
    }
}
