#Intent.podspec
Pod::Spec.new do |s|
s.name         = "Intent"
s.version      = "1.0.3"
s.summary      = "A solution for iOS modules and components separation. You can route to viewController or perform native block with url."

s.homepage     = "https://github.com/Jerry0523/Intent"
s.license      = 'MIT'
s.author       = { "Jerry Wong" => "jerrywong0523@icloud.com" }
s.platform     = :ios, "8.0"
s.ios.deployment_target = "8.0"
s.source       = { :git => "https://github.com/Jerry0523/Intent.git", :tag => s.version}
s.requires_arc = true

s.default_subspec = 'Core'

s.subspec 'Core' do |core|
core.source_files = 'Intent/*.swift'
end

s.subspec 'Transition' do |tran|
tran.source_files = 'Intent/Transition/*.swift'
tran.dependency 'Intent/Core'
end

end
