Pod::Spec.new do |s|
  s.name         = "coobjc"
  s.version      = "1.0.0"
  s.summary      = "Coroutine support for Objective-C"

  s.description  = <<-DESC
                    This library provides coroutine support for Objective-C and Swift. We added await method、generator and actor model like C#、Javascript and Kotlin. For convenience, we added coroutine categories for some Foundation and UIKit API in cokit framework like NSFileManager, JSON, NSData, UIImage etc. We also add tuple support in coobjc
                   DESC

  s.homepage     = "http://github.com/alibaba/coobjc"
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
           Alibaba-INC copyright
    LICENSE
  }

  s.author       = { "pengyutang125" => "pengyutang125@sina.com" }
  s.platform     = :ios

  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.source =  { :git => "git@github.com:alibaba/coobjc.git", :branch => 'master' } 
  s.source_files = 'coobjc/**/*.{h,m,s,c,mm}' 

  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = ['coobjc/util/co_tuple.m', 'coobjc/objc/co_autorelease.mm']
  end

  s.dependency 'fishhook'
end
