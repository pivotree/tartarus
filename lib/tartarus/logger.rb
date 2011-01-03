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
    base.serialize :request, ::Hash
  end

  module ClassMethods
    def log(env, exception)
      logged = create do |logged_exception|
        controller = env['action_controller.instance']
        group_id = "#{exception.class.name}#{exception.message.gsub(/(#<.+):(.+)(>)/,'\1\3')}#{controller.controller_path}#{controller.action_name}" 
       
        logged_exception.exception_class = exception.class.name
        logged_exception.controller_path = controller.controller_path
        logged_exception.action_name = controller.action_name
        logged_exception.message = exception.message
        logged_exception.backtrace = exception.backtrace * "\n"
        debugger
        logged_exception.request = self.normalize_request_data(env)
        logged_exception.group_id = Digest::SHA1.hexdigest(group_id)
      end
      logged.handle_notifications
      logged
    end

    def normalize_request_data(env)
      request = env['action_controller.instance'].request
 
      request_details = {
        :enviroment => { :process => $$, :server => `hostname -s`.chomp },
        :session => { :variables => request.env['rack.session'].to_hash, :cookie => request.env['rack.request.cookie_hash'] },
        :http_details => { 
          :method => request.method.to_s.upcase,
          :url => "#{request.protocol}#{env["HTTP_HOST"]}#{request.request_uri}",
          :format => request.format.to_s,
          :parameters => request.filtered_parameters
        }
      }

      env.each_pair do |key, value|
        request_details[:enviroment][key.downcase] = value if key.match(/^[A-Z_]*$/)
      end

      return request_details
    end

  end
end
