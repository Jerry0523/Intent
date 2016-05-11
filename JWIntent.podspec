#JWIntent.podspec
Pod::Spec.new do |s|
s.name         = "JWIntent"
s.version      = "1.0.0"
s.summary      = "A solution for iOS modules and components separation. You can route to viewController or perform native block with url."

s.homepage     = "https://github.com/Jerry0523/JWIntent"
s.license      = 'MIT'
s.author       = { "Jerry Wong" => "jerrywong0523@icloud.com" }
s.platform     = :ios, "7.0"
s.ios.deployment_target = "7.0"
s.source       = { :git => "https://github.com/Jerry0523/JWIntent.git", :tag => s.version}
s.source_files  = 'JWIntent/*.{h,m}'
s.requires_arc = true
end