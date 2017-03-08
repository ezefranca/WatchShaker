# WatchShaker
> Simple motion detector for ⌚️ (watchOS) shake gesture.

[![Swift Version][swift-image]][swift-url] [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/WatchShaker.svg)](https://img.shields.io/cocoapods/v/WatchShaker.svg) [![Platform](https://img.shields.io/cocoapods/p/WatchShaker.svg?style=flat)](http://cocoadocs.org/docsets/WatchShaker)

<img src="http://www.ezefranca.com/img/bwshaker.jpg" width="400" height="300" />

 WatchShaker is a watchOS helper to get your ⌚️ shake movements

## Requirements

- watchOS 3.0+
- Xcode 8.0+

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `WatchShaker` by adding it to your `Podfile`:

```ruby
use_frameworks!
pod 'WatchShaker'
```
#### Manually
1. Download and drop ```WatchShaker.swift``` in your project to your watch target.  
2. Congratulations!  

## Usage example

```swift
import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }

    var shaker:WatchShaker = WatchShaker(shakeSensibility: .shakeSensibilityNormal, delay: 0.2)

    override func willActivate() {

        super.willActivate()
        shaker.delegate = self
        shaker.start()
    }

    override func didDeactivate() {

        super.didDeactivate()
        shaker.stop()

    }

}

extension InterfaceController: WatchShakerDelegate
{
    func watchShakerDidShake(_ watchShaker: WatchShaker) {
        print("YOU HAVE SHAKEN YOUR ⌚️⌚️⌚️")
    }

    func watchShaker(_ watchShaker: WatchShaker, didFailWith error: Error) {
        print(error.localizedDescription)
    }
}

```

![](https://media.giphy.com/media/l0HlEj4BChAiyCaje/giphy.gif)

## Contribute

We would love for you to contribute to **WatchShaker**, check the ``LICENSE`` file for more info.

## Meta

Ezequiel França – [@ezefranca](https://twitter.com/ezefranca) – ezequiel.ifsp@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
