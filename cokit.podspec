Pod::Spec.new do |s|
  s.name         = "cokit"
  s.version      = "1.0.0"
  s.summary      = "cokit."

  s.description  = <<-DESC
                    cokit.
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
  s.requires_arc = true

  s.source =  { :git => "git@github.com/alibaba/coobjc.git", :branch => 'master' } 
  s.source_files = 'cokit/cokit/**/*.{h,m}' 
  
  s.dependency "coobjc"
end
