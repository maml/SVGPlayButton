# SVGPlayButton

[![Version](https://img.shields.io/cocoapods/v/SVGPlayButton.svg?style=flat)](http://cocoapods.org/pods/SVGPlayButton)
[![License](https://img.shields.io/cocoapods/l/SVGPlayButton.svg?style=flat)](http://cocoapods.org/pods/SVGPlayButton)
[![Platform](https://img.shields.io/cocoapods/p/SVGPlayButton.svg?style=flat)](http://cocoapods.org/pods/SVGPlayButton)
[![Twitter](https://img.shields.io/badge/twitter-%40mattloseke-blue.svg)](http://twitter.com/mattloseke)

![](./screenshot.png)

## About

This button was built to control audio playback. It could probably be used for other stuff but, playing back audio in Tincan is what prompted me to build it.

It toggles between 'play' and 'pause', has a circle around it, and has the capability to display a 'progress track'. It's a sub-class of UIButton and all visual elements are SVG which means it will scale infinitely up and/or down. The example app demonstrates some of the scaling capability via a slider as well as an example of how to update the button's progress.

It has default colors which can be set to whatever you like. The colors that can be set are:
* ```progressTrackColor``` - the outer circle
* ```progressColor``` - the progress circle that fills in the 'track'
* ```playColor``` - color of the play shape / triangle
* ```pauseColor``` - color of the pause lines

It has two closures: ```willPlay()``` and ```willPause()```. These are optionals and if have been set, will be called just before the button 'plays' or 'pauses'. The button itself is not responsible for playing or pausing anything and so the closures are a way of letting the button say, "heyyy I'm going to be in a state that indicates something's being played so you should probably play something," to whatever has maintained a reference to it.

There is an ```isPlaying``` boolean attribute that will return true or false depending on if the button's 'playing' or not.

## Usage

Drag a button onto your storyboard. Set its class to SVGPlayButton and Type to Custom. Connect an outlet to your controller. If you wish set the button's ```willPlay()``` and ```willPause()``` closures to something meaningful and useful to your app. Override default colors as needed.

In a view controller this could look something like:

```swift
@IBOutlet weak var progressButton: SVGPlayButton!

func viewDidLoad() {
    super.viewDidLoad()
    self.progressButton.willPlay = { self.progressButtonWillPlayHandler() }
    self.progressButton.willPause = { self.progressButtonWillPauseHandler() }
    self.progressButton.progressTrackColor = UIColor.lightGrayColor()
    self.progressButton.progressColor = UIColor.darkGrayColor()
    self.progressButton.playColor = UIColor.grayColor()
    self.progressButton.pauseColor = UIColor.grayColor()
}

private func willPlayHandler() {
    print("willPlay")
}

private func willPauseHandler() {
    print("willPause")
}
```

## Requirements
iOS 8.0+
## Installation

SVGPlayButton is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SVGPlayButton', '~> 0.2.3'
```

## Author

* Matthew Loseke, mloseke@gmail.com
* [@mattloseke](twitter.com/mattloseke)

## License

SVGPlayButton is available under the MIT license. See the LICENSE file for more info.
