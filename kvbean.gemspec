$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kvbean/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kvbean"
  s.version     = Kvbean::VERSION
  s.authors     = ["Sen"]
  s.email       = ["sen9ob@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Kvbean."
  s.description = "TODO: Description of Kvbean."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"

  s.add_development_dependency "sqlite3"
end
