Pod::Spec.new do |s|
  s.name         = "GrailsSpringSecurityRestObjc"
  s.version      = "0.1"
  s.summary      = "An Objective-C framework to handle authentication against a Grails App"
  s.description  = "This framework facilitates login, logout and JWT access token refresh against a Grails app secured by Grails Spring Security Rest Plugin."
  s.homepage     = "http://grails.org"
  s.license      = "MIT"
  s.author             = { "sdelamo" => "sergio.delamo@softamo.com" }
  s.social_media_url   = "http://twitter.com/sdelamo"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/grails/grails-spring-security-core-rest-objc.git", :tag => "#{s.version}" }
  s.source_files  = "GrailsSpringSecurityRestObjc", "GrailsSpringSecurityRestObjc/*.{h,m}"
  s.public_header_files = "GrailsSpringSecurityRestObjc/*.h"
end
