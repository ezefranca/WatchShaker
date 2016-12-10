# WatchShaker
> Experimental Shake for your ⌚️

[![Swift Version][swift-image]][swift-url]
[![Build Status][travis-image]][travis-url]
[![License][license-image]][license-url]
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EZSwiftExtensions.svg)](https://img.shields.io/cocoapods/v/LFAlertController.svg)  
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)

![](header.png)

 WatchShaker is a watchOS helper to get your ⌚️ shake moviment

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

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/YourLibrary.framework` to an iOS project.

```
github "yourUsername/yourlibrary"
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
    func didShake() {
        print("YOU SHAKE YOUR ⌚️⌚️⌚️")
    }
    
    func error(with error: Error) {
        print(error.localizedDescription)
    }
}
```

## Contribute

We would love for you to contribute to **YourLibraryName**, check the ``LICENSE`` file for more info.

## Meta

Ezequiel França – [@ezefranca](https://twitter.com/ezefranca) – ezequiel.ifsp@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/ezefranca/github-link](https://github.com/dbader/)

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
