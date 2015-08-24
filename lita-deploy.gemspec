Gem::Specification.new do |spec|
  spec.name          = 'lita-deploy'
  spec.version       = '0.1.0'
  spec.authors       = ['Jaison Erick']
  spec.email         = ['jaisonreis@gmail.com']
  spec.description   = 'Lita handler for github flow'
  spec.summary       = 'Lita handler for github flow'
  spec.homepage      = 'http://github.com/jaisonerick/lita-deploy'
  spec.license       = 'MIT'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '>= 4.4'

  spec.add_dependency 'octokit', '~> 4.0'
  spec.add_dependency 'actionview', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
end
