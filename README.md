A solution for iOS modules and components separation. You can route to viewController or perform native block with url.

Features
-------

### You can register LoginViewController by the following

```objective-c
[JWIntentContext registerRouterClass:"LoginViewController"
                              forKey:@"login"];
```

### You can register Block by the following

```objective-c
[JWIntentContext registerHandler:^(NSDictionary *param) {
    NSLog(@"%@", param[@"message"]);
} 
                         forKey:@"testAlert"];
```

### You can route to LoginViewController by router key

```objective-c
JWRouter *intent = [[JWRouter alloc] initWithSource:self
                                          routerKey:@"login"];
[intent submit];

```

### Or you can route to LoginViewController by remote URL

```objective-c
JWIntent *intent = [JWIntent intentWithURLString:@"router://login?extraData={\"username\":\"jerry\"}" 
                                         context:nil];
[intent submit];

```

### Or you can perform block by remote URL

```objective-c
JWIntent *intent = [JWIntent intentWithURLString:@"handler://testAlert?extraData={\"title\":\"Hello Alert\",\"message\":\"I have a message for you.\"}" 
                                         context:nil];
[intent submit];

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
platform :ios, '7.0'

pod 'JWIntent'
```

Then, run the following command:

```bash
$ pod install
```

License
-------
(MIT license)
