Gem::Specification.new {|s|
	s.name         = 'namedic'
	s.version      = '0.0.6.4'
	s.author       = 'meh.'
	s.email        = 'meh@paranoici.org'
	s.homepage     = 'http://github.com/meh/namedic'
	s.platform     = Gem::Platform::RUBY
	s.summary      = 'Plain stupid named parameters. Moved to https://github.com/meh/ruby-call-me'
	s.files        = Dir.glob('lib/**/*.rb')
	s.require_path = 'lib'

	s.add_dependency 'refining'

	s.add_development_dependency 'rake'
	s.add_development_dependency 'rspec'
}
