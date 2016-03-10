$LOAD_PATH << File.dirname(__FILE__)
load 'deploy'

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'deploy/assets'
require 'payments-deployment/bootstrap'
# require 'payments-deployment/workers'

load 'config/deploy' # remove this line to skip loading any of the default tasks
