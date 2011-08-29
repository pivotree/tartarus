class Tartarus::Notifiers::Mail < ActionMailer::Base
  
  def self.notify(config, exception)
    notification(config, exception).deliver
  end
  
  def notification(config, exception)
    subject = "#{config['prefix']}Exception raised at #{exception.controller_path}##{exception.action_name} (#{exception.exception_class}) #{exception.message}" 
    mail(:to => config['address'], :from => config['sender'], :subject => subject) do |format|
      format.text do 
        render :text => %{
          A new exception was raised (#{exception.created_at.strftime("%m/%d/%Y %I:%M%p")}):

          Class    : #{exception.exception_class}
          Location : #{exception.controller_path}##{exception.action_name} 
          Message  : #{exception.message}
          Count    : #{exception.group_count}

          Backtrace: 
          #{exception.backtrace}

          Request: 
          #{exception.request}
        }
      end
    end
  end

end
