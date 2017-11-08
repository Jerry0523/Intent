A solution for iOS modules and components separation. You can route to viewController or perform native block with url.

Features
-------

### You can register LoginViewController by the following

```swift
IntentCtx.default.register(LoginViewController.self, forKey: "login")

```

### You can register Block by the following

```swift
IntentCtx.default.register({ (param) in
    print(param)
}, forKey: "showAlert")

```

### You can route to LoginViewController by router key

```swift
let router = try? Router.init(key: "login", extra: ["stringValue": "This message came from a router"])
router?.submit()

```

### You can route with custom transition

```swift
var router = try? Router.init(key: "login", extra: ["stringValue": "This message came from a router"])
router?.transition = SystemTransition.init(axis: .horizontal, style: .zoom(factor: 0.8))
router?.submit()

```

### You can specify how to route to the dest

```swift
var router = try? Router.init(key: "login", extra: ["stringValue": "This message came from a router"])
router?.config = .present([.fakePush, .wrapNC])
router?.transition = SystemTransition.init(axis: .horizontal, style: .zoom(factor: 0.8))
router?.submit()

```
### Currently, we support

- Present
- Push
- Switch
- Modal
- Child

### You can route to LoginViewController by remote URL

```swift
let router = try? Router.init(urlString: "router://login?stringValue=This message came from a url string")
router?.submit()

```

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries. You can install it with the following command:

```bash
$ gem install cocoapods
```
#### Podfile

To integrate JWIntent into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'JWIntent'
```

Then, run the following command:

```bash
$ pod install
```

License
-------
(MIT license)
