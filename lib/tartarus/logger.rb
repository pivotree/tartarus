module Tartarus::Logger
  def self.included(base)
    base.extend ClassMethods
    base.serialize :request
  end

  module ClassMethods
    def log(controller, exception)
      create do |logged_exception|
        group_id = "#{exception.class.name}#{exception.message}#{controller.controller_path}#{controller.action_name}" 
    
        logged_exception.exception_class = exception.class.name
        logged_exception.controller_path = controller.controller_path
        logged_exception.action_name = controller.action_name
        logged_exception.message = exception.message
        logged_exception.backtrace = exception.backtrace * "\n"
        logged_exception.request = controller.normalize_request_data_for_tartarus
        logged_exception.group_id = Digest::SHA1.hexdigest(group_id)
      end
    end

  end
end
