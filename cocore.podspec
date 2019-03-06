Pod::Spec.new do |s|
  s.name         = "cocore"
  s.version      = "1.1.0"
  s.summary      = "coobjc's core implement"

  s.description  = <<-DESC
                    This library provides coroutine core support for Objective-C and Swift. coobjc and coswift depend on this sdk.
                   DESC

  s.homepage     = "https://github.com/alibaba/coobjc"
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
           Alibaba-INC copyright
    LICENSE
  }

  s.author       = { "pengyutang125" => "pengyutang125@sina.com" }
  s.platform     = :ios

  s.ios.deployment_target = '8.0'

  s.source =  { :git => "https://github.com/alibaba/coobjc.git", :tag => '1.0.0' } 
  s.source_files = ['coobjc/core/*.{h,m,s,c,mm}', 'coobjc/util/*.{h,m}', 'coobjc/csp/*.{h,m}', 'coobjc/objc/co_autorelease.{h,mm}']
  s.requires_arc = ['coobjc/api/*.m', 'coobjc/core/*.m', 'coobjc/csp/*.m', 'coobjc/promise/*.m', 'coobjc/util/*.m']

  s.library = 'c++'
  s.dependency 'fishhook', '~> 0.2.0'
end
