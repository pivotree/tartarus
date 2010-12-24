module Tartarus::Logger
  def group_count
    self.class.count( :conditions => ["group_id = ?", group_id] )
  end
 
  def handle_notifications
    notification_address =  Tartarus.configuration['notification_address']
    return unless notification_address.present? 
    Tartarus::Notifiers::Mail.deliver_notification( notification_address, self ) if group_count == 1 or (group_count%Tartarus.configuration['notification_threshold']).zero?
  end

  def self.included(base)
    base.extend ClassMethods
    base.serialize :request
  end

  module ClassMethods
    def log(controller, exception)
      logged = create do |logged_exception|
        group_id = "#{exception.class.name}#{exception.message.gsub(/(#<.+):(.+)(>)/,'\1\3')}#{controller.controller_path}#{controller.action_name}" 
    
        logged_exception.exception_class = exception.class.name
        logged_exception.controller_path = controller.controller_path
        logged_exception.action_name = controller.action_name
        logged_exception.message = exception.message
        logged_exception.backtrace = exception.backtrace * "\n"
        logged_exception.request = controller.normalize_request_data_for_tartarus
        logged_exception.group_id = Digest::SHA1.hexdigest(group_id)
      end
      logged.handle_notifications
      logged
    end

  end
end
