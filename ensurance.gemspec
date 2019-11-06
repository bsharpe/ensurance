lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ensurance/version'

Gem::Specification.new do |spec|
  spec.name          = 'ensurance'
  spec.version       = Ensurance::VERSION
  spec.authors       = ['Ben Sharpe']
  spec.email         = ['bsharpe@gmail.com']

  spec.summary       = 'Add ability to ensure ActiveRecord models'
  spec.description   = 'A handy shortcut for user = user.is_a?(User) ? user : User.find(user)'
  spec.homepage      = 'https://github.com/bsharpe/ensurance'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 3', '<= 6'

  spec.add_development_dependency 'activerecord', '>= 3'
  spec.add_development_dependency 'awesome_print', '>= 1.0', '< 2'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'globalid', '>= 0.3.6', '< 2'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'sqlite3', '>= 1.3.0', '< 4'
end
