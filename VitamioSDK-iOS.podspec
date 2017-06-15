#
#  Be sure to run `pod spec lint VitamioSDK-iOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "VitamioSDK-iOS"
  s.version      = "1.0.1"
  s.summary      = "Vitamio Player SDK for iOS"
  s.homepage     = "https://github.com/chenXming/VitamioPlayer.git"
  s.license      = "MIT"

  s.author             = { "chenxiaoming" => "chenxiaoming@asean-go.com" }
  s.ios.deployment_target = "7.0"
 
  s.source        = {:git =>"https://github.com/chenXming/VitamioPlayer.git", :commit =>'606550e6dc74df7bbcb53ee4e66e8348f0c5759b'}

  s.source_files  = "Vitamio_Player", "Vitamio_Player/Vitamio/include/Vitamio/*.h"
  s.public_header_files = "Vitamio_Player/Vitamio/include/Vitamio/*.h"
  s.vendored_libraries = "Vitamio_Player/Vitamio/*.a"

  s.frameworks = "Foundation","UIKit","AVFoundation","AudioToolbox","CoreGraphics","CoreMedia","CoreVideo","MediaPlayer","OpenGLES","QuartzCore"

  s.libraries = "bz2", "z","stdc++","iconv"
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"




  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

end
