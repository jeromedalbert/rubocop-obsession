require_relative 'lib/rubocop/obsession/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-obsession'
  spec.version = Rubocop::Obsession::VERSION
  spec.authors = ['Jerome Dalbert']
  spec.email = ['jerome.dalbert@gmail.com']

  spec.summary = 'Code style checking for Ruby files.'
  spec.description = 'A collection of RuboCop cops I have been obsessed with.'
  spec.homepage = 'https://github.com/jeromedalbert/rubocop-obsession'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jeromedalbert/rubocop-obsession'

  spec.files = Dir['LICENSE.txt', 'README.md', 'config/**/*', 'lib/**/*']
  spec.licenses = ['MIT']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'rubocop'
end
