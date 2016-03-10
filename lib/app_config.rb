require 'ostruct'
require 'yaml'
require 'erb'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'
require File.expand_path(File.dirname(__FILE__)+'/../config/initializers/openstruct_additions')

class AppConfig
  class_attribute :config

  class << self
    def reload!
      _config = {}

      # for each yml file
      yml_files = "#{File.expand_path(File.dirname(__FILE__)+'/..')}/config/configurations/*.yml"
      Dir[yml_files].each do |f|
        # load it into openstruct
        this_file = YAML.load(ERB.new(File.read(f)).result).with_indifferent_access
        # capture filename without extension
        this_name = File.basename(f, ".yml")

        # capture environment specific fields
        env_config = this_file[ENV['RAILS_ENV'] || 'development']

        # merge environment specific ones into common fields
        # (or just use them as common ones if no commons exist)
        this_file[:common] ||= {}
        this_file[:common].deep_merge!(env_config) if env_config

        # save openstruct version of the common set
        _config[this_name] = this_file[:common]
      end

      # write hash to globally accessible variable
      self.config = _config.to_openstruct
    end

    def method_missing(method_sym, *arguments, &block)
      return config.send(method_sym) if config.respond_to?(method_sym)
      super
    end
    def respond_to?(method_sym, include_private = false)
      return true if config.respond_to?(method_sym)
      super
    end
  end
end

AppConfig.reload!
