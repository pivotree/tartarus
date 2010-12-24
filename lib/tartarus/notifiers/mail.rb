class Tartarus::Notifiers::Mail < ActionMailer::Base
  self.mailer_name = 'tartarus_notifier'
  self.view_paths << "#{File.dirname(__FILE__)}/../../../views"
  
  def notification( to, exception )
    @recipients = to
    @from = Tartarus.configuration['sender']
    @subject = "Exception raised at #{exception.controller_path}##{exception.action_name} (#{exception.exception_class}) #{exception.message}" 
    @body[:exception] = exception
  end
end
