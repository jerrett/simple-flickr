# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{simple-flickr}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jerrett Taylor"]
  s.date = %q{2010-05-10}
  s.description = %q{A wrapper for Flickrs REST API.}
  s.email = %q{jerrett@gmail.com}
  s.files = ["README", "Rakefile", "spec/client_spec.rb", "spec/person_spec.rb", "spec/photo_set_spec.rb", "spec/photo_spec.rb", "spec/photos_spec.rb", "spec/proxy_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "lib/simple-flickr", "lib/simple-flickr/client.rb", "lib/simple-flickr/person.rb", "lib/simple-flickr/photo.rb", "lib/simple-flickr/photo_set.rb", "lib/simple-flickr/photos.rb", "lib/simple-flickr/proxy.rb", "lib/simple-flickr.rb"]
  s.homepage = %q{http://github.com/jerrett/simple-flickr}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A wrapper for Flickrs REST API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0.8.0"])
    else
      s.add_dependency(%q<hpricot>, [">= 0.8.0"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0.8.0"])
  end
end
