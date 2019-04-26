Pod::Spec.new do |s|
  s.name         = "coswift"
  s.version      = "1.2.0"
  s.summary      = "A coroutine framework for swift."

  s.description  = <<-DESC
                    A coroutine framework for swift, using coobjc.
                   DESC

  s.homepage     = "https://github.com/alibaba/coobjc"
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
           Alibaba-INC copyright
    LICENSE
  }

  s.author       = { "pengyutang125" => "pengyutang125@sina.com" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.12'
  s.requires_arc = true

  s.source =  { :git => "https://github.com/alibaba/coobjc.git", :tag => '1.2.0' } 
  s.source_files = 'coswift/*.{h,swift}'

  s.swift_version = '4.2'

  s.dependency 'cocore',  '~> 1.2.0'
end
