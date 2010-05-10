require 'rake'
require 'rake/gempackagetask'

Dir[ "tasks/**/*.rake" ].each { | tasks | load tasks } 

desc "Run specs"
task :default => :spec

spec = Gem::Specification.new do |s|
  s.name         = 'simple-flickr'
  s.version      = '0.1.1'
  s.summary      = "A wrapper for Flickrs REST API"
  s.description  = "A wrapper for Flickrs REST API."

  s.author       = "Jerrett Taylor"
  s.email        = "jerrett@gmail.com"
  s.homepage     = "http://github.com/jerrett/simple-flickr"
  
  # code
  s.require_path = "lib"
  s.files        = %w( README Rakefile ) + Dir["{spec,lib}/**/*"]
 
  # rdoc
  s.has_rdoc         = false
 
  # Dependencies
  s.add_dependency "hpricot", [">= 0.8.0"]
  
  # Requirements
  s.required_ruby_version = ">= 1.8.6"
  
  s.platform = Gem::Platform::RUBY
end

desc "create .gemspec file (useful for github)"
task :gemspec do
  filename = "#{spec.name}.gemspec"
  File.open(filename, "w") do |f|
    f.puts spec.to_ruby
  end
end
