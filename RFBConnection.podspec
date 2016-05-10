Pod::Spec.new do |spec|
  spec.name         = 'RFBConnection'
  spec.version      = '0.1.1'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/ReDetection/RFBConnection'
  spec.authors      = { 'Liu Leon' => 'liu.l.leon@gmail.com' }
  spec.summary      = 'RFB (VNC) client library for iOS'

  spec.platform = :ios, '6.0'
  spec.source       = { :git => 'https://github.com/ReDetection/RFBConnection.git', :tag => "#{spec.version}" }
  spec.source_files = 'NPDesktop/{datamodel,protocol,utilities}/*.{h,m,c}'
  spec.prefix_header_file = 'NPDesktop/NPDesktop-Prefix.pch'

  spec.dependency 'DFJPEGTurbo', '~> 0.2.1'
  spec.dependency 'CocoaAsyncSocket', '~> 7.4.3'
  spec.libraries = 'z'
end
