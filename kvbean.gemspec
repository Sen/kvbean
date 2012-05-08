$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kvbean/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kvbean"
  s.version     = Kvbean::VERSION
  s.authors     = ["Sen"]
  s.email       = ["sen9ob@gmail.com"]
  s.homepage    = "https://github.com/Sen/kvbean"
  s.summary     = "Redis on ActiveRecord"
  s.description = "Make redis on rails life easier"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"
  s.add_runtime_dependency "redis", "~> 2.2.2"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "activemodel"
end
