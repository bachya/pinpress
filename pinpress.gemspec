require File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'pinpress', 'constants.rb')
Gem::Specification.new do |spec|
  spec.name             = 'pinpress'
  spec.version          = PinPress::VERSION
  spec.authors          = ["Aaron Bach"]
  spec.email            = ["bachya1208@googlemail.com"]
  spec.summary          = PinPress::SUMMARY
  spec.description      = PinPress::DESCRIPTION
  spec.homepage         = 'https://github.com/bachya/pinpress'
  spec.license          = 'MIT'

  spec.files            = `git ls-files -z`.split("\x0")
  spec.executables      = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files       = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths    = ["lib"]

  spec.add_development_dependency('aruba', '0.5.4')
  spec.add_development_dependency('rake', '10.1.1')
  spec.add_development_dependency('rspec', '2.14.1')
  spec.add_development_dependency('yard', '0.8.7.4')
  spec.add_runtime_dependency('chronic', '0.10.2')
  spec.add_runtime_dependency('clippy', '2.1.0')
  spec.add_runtime_dependency('cliutils', '~> 2')
  spec.add_runtime_dependency('gli', '2.9.0')
  spec.add_runtime_dependency('htmlentities', '~> 4')
  spec.add_runtime_dependency('pinboard', '0.1.1')
end
