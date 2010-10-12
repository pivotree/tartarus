module Tartarus::Rescue
  def self.included(base)
    base.class_eval do
      alias_method_chain :rescue_action, :tartarus
    end
  end
  
  def rescue_action_with_tartarus(exception)
    is_exception = response_code_for_rescue(exception) == :internal_server_error

    if is_exception and Tartarus.logging_enabled?
      Tartarus.log(self, exception)
    end

    rescue_action_without_tartarus(exception)
  end
    
  def normalize_request_data_for_tartarus
    enviroment = request.env.dup
    filtered_params = respond_to?(:filter_parameters) ? filter_parameters(request.parameters) : request.parameters.dup

    request_details = {
      :enviroment => { :process => $$, :server => `hostname -s`.chomp },
      :session => { :variables => enviroment['rack.session'].to_hash, :cookie => enviroment['rack.request.cookie_hash'] },
      :http_details => { 
        :method => request.method.to_s.upcase,
        :url => "#{request.protocol}#{request.env["HTTP_HOST"]}#{request.request_uri}",
        :format => request.format.to_s,
        :parameters => filtered_params
      }
    }

    enviroment.each_pair do |key, value|
      request_details[:enviroment][key.downcase] = value if key.match(/^[A-Z_]*$/)
    end

    return request_details
  end
end
