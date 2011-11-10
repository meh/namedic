Gem::Specification.new {|s|
	s.name         = 'namedic'
	s.version      = '0.0.6.2'
	s.author       = 'meh.'
	s.email        = 'meh@paranoici.org'
	s.homepage     = 'http://github.com/meh/namedic'
	s.platform     = Gem::Platform::RUBY
	s.summary      = 'Plain stupid named parameters'
	s.files        = Dir.glob('lib/**/*.rb')
	s.require_path = 'lib'

	s.add_development_dependency 'rake'
	s.add_development_dependency 'rspec'
}
