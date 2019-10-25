Pod::Spec.new do |s|

  s.name         = "CPFMDBManager"
  s.version      = "1.0.2"
  s.summary      = "数据库管理者"
  s.homepage     = "https://github.com/cp271007323/CPFMDBManager.git"
  s.license      = "MIT"
  s.author       = { "cp271007323" => "271007323@qq.com" }
  s.ios.deployment_target = "9.0"
  s.frameworks = "Foundation", "UIKit"
  s.dependency 'FMDB'
  s.source = { :git => "https://github.com/cp271007323/CPFMDBManager.git", :tag => s.version }
  s.source_files =  "CPFMDBManager" , "CPFMDBManager/*.{h.m}"

end


