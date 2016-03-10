$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'deploy')

set :stages, %w(production uat)
set :default_stage, 'uat'

set :user, 'ubergateway_deploy'
set :application, 'email-service'
set :repository, 'github:nX8igTYAm2iskVhn/email-service.git'

set :bundle_without,  [:everyone_except_rubymine] # workaround due to rubymine debugger issues

set :branch, fetch(:branch, 'master')

require 'payments-deployment/deploy'

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      logger.info "Skipping asset pre-compilation because we have no assets"
    end
  end
end

namespace :deploy do
  namespace :zero_downtime do
    namespace :heartbeat do
      task :disable, :except => { :no_release => true }, :roles => [:app], :hosts => lambda { current_host_list } do
        logger.info "heartbeat LB functionality is diabled"
      end

      task :enable, :except => { :no_release => true }, :roles => [:app], :hosts => lambda { current_host_list } do
        logger.info "heartbeat LB functionality is diabled"
      end

      task :check, :except => { :no_release => true }, :roles => [:app], :hosts => lambda { current_host_list } do
        logger.info "heartbeat LB functionality is diabled"
      end
    end

    namespace :app_server do
      task :smoketest, :except => { :no_release => true }, :roles => [:app], :hosts => lambda { current_host_list } do
        logger.info "Skipping Smoketesting..."
      end
    end
  end
end


        require './config/boot'
        require 'airbrake/capistrano'
