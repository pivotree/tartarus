require 'yaml'
require 'will_paginate'

class Tartarus
  module Notifiers; end

  class << self
    def configuration
      @cached_configuration ||= YAML.load_file("#{Rails.root}/config/exceptions.yml")[Rails.env]
    end

    def logger_class
      configuration['logger_class'].constantize
    end
    
    def logging_enabled?
      configuration['logging_enabled'] == true
    end

    def log(controller, exception)
      logger_class.log(controller, exception) if logging_enabled?
    end
  end
end

require 'tartarus/rack'
require 'tartarus/logger'
require 'tartarus/notifiers/mail'
require 'tartarus/railtie'

