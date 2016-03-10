# NEVER use debug in production!
self.class::DEFAULTS[:logger].level = Logger::INFO

pid_file = "/var/nX8igTYAm2iskVhn/run/email-service/unicorn.pid"
pid pid_file
stderr_path "/var/nX8igTYAm2iskVhn/log/email-service/unicorn.log"
working_directory "/var/nX8igTYAm2iskVhn/email-service/current/"
preload_app true
worker_processes 10
listen "/var/nX8igTYAm2iskVhn/run/email-service/unicorn.sock"

# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

# ensure Unicorn doesn't use a stale Gemfile when restarting
# more info: https://willj.net/2011/08/02/fixing-the-gemfile-not-found-bundlergemfilenotfound-error/
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "/var/nX8igTYAm2iskVhn/email-service/current/Gemfile"
end

before_fork do |server, worker|
  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{pid_file}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end


require File.expand_path(File.dirname(__FILE__)+'/../lib/service_helpers.rb')
after_fork do |server, worker|
  ServiceHelpers.reconnect_services!
end
