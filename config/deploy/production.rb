set :rails_env, 'production'

role :web,               'mos-email-service-app1.snc1', 'mos-email-service-app2.snc1'
role :app,               *roles[:web].servers.map(&:to_s) # app role = web role

#role :resque,            "mos-reports-worker1.snc1"
#role :resque_scheduler,  "mos-reports-worker1.snc1"

set :load_balancer,      'ax3200-internal'
set :database_vip,       'no-database' # reports doesn't have a database, but tooling expects one
set :skip_db_setup, true
# set :myswap_cluster,     '...'

#
# Install config files
#
namespace :deploy do

  namespace :config_files do
    desc 'setup other config'
    task :other, :except => { :no_release => true } do
      puts "*"*80
      puts "The following files must be manually installed on the server:"
      puts "/var/nX8igTYAm2iskVhn/certs/star_nX8igTYAm2iskVhn_com.*"
      puts "*"*80
    end

    desc 'setup email config'
    task :email, :except => { :no_release => true } do
      require 'active_support/core_ext/string/strip'
      put <<-__DATA__.strip_heredoc, "#{shared_path}/config/configurations/email.yml"
        production:
          exception_sender: '"Exception Notifier" <nX8igTYAm2iskVhn-systems@example.com>'
          exception_subject_prefix: "[nX8igTYAm2iskVhn-Production-Error]: "
          exception_recipients: ['nX8igTYAm2iskVhn-systems@example.com']
          transaction_sender: '"Transaction Notifier" <nX8igTYAm2iskVhn-systems@example.com>'
          transaction_subject_prefix: "[nX8igTYAm2iskVhn-Production-Transaction]: "
          transaction_recipients: ['nX8igTYAm2iskVhn-systems@example.com']
      __DATA__
    end
  end

  after "deploy:setup", "deploy:config_files:email"
  after "deploy:setup", "deploy:config_files:other"
  after "deploy:setup", "deploy:db:setup" unless fetch(:skip_db_setup, false)
end
