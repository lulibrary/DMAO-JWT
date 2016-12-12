require 'rake'
require 'rake/testtask'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs    << 'spec'
  t.warning = false
end

task default: :test
task spec: :test

namespace :db do
  task :load_config do
    require_relative 'config/environment'
    require_relative 'app/jwt_service_application'
  end
end