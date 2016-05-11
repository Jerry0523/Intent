A solution for iOS modules and components separation. You can route to viewController or perform native block with url.

Features
-------

### You can register LoginViewController by the following

```objective-c
[JWIntentContext registerViewController:"LoginViewController"
                                 forKey:@"login"];
```

### You can register Block by the following

```objective-c
[JWIntentContext registerCallBack:^(NSDictionary *param) {
    NSLog(@"%@", param[@"message"]);
} 
                           forKey:@"testAlert"];
```

### You can route to LoginViewController by target class name

```objective-c
JWIntent *intent = [[JWIntent alloc] initWithSource:self
                                    targetClassName:@"LoginViewController"];
[intent submit];

```

### Or you can route to LoginViewController by remote URL

```objective-c
JWIntent *intent = [[JWIntent alloc] initWithSource:self
                                          targetURL:@"router://login?extraData={\"username\":\"jerry\"}"];
[intent submit];

```

### Or you can perform block by remote URL

```objective-c
JWIntent *intent = [[JWIntent alloc] initWithSource:self
                                          targetURL:@"callBack://testAlert?extraData={\"title\":\"Hello Alert\",\"message\":\"I have a message for you.\"}"];
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
