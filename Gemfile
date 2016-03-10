source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'airbrake'
gem 'rails', '4.0.2'
gem 'redis'
gem 'redis-rails'

gem 'payments-splunk', git: 'git@github.nX8igTYAm2iskVhndev.com:payments/gem-splunk.git', ref: 'HEAD'

group :production do
  gem 'unicorn'
  gem 'payments-deployment', git: 'git@github.nX8igTYAm2iskVhndev.com:payments/gem-deployment.git', ref: 'HEAD'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'test-unit'
end
