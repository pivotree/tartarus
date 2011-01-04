require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tartarus::Logger do
  describe "#log" do
    before(:each) do
      Tartarus.stub(:configuration).and_return({ 'test' => { :enabled => true, "logger_class"=>"LoggedException" } })
      LoggedException.stub!(:normalize_request_data).and_return({})
      @controller = { 'action_controller.instance' => mock('controller', :controller_path => 'home', :action_name => 'index', :request => fake_controller_request) }
      @exception = StandardError.new('An error has occured!')
      @exception.stub!(:backtrace).and_return(['one', 'two', 'three'])
    end

    it "should create a group_id for grouping of exceptions that are the same" do
      @logged_exception = LoggedException.log(@controller, @exception)
      @logged_exception.group_id.should == 'ea61658eacfe0930ae2b318297ab51a3c0b5668c'
    end

    it "should convert the backtrace from an array to a string seperated by newlines" do
      @logged_exception = LoggedException.log(@controller, @exception)
      @logged_exception.backtrace.should be_an_instance_of(String)
      @logged_exception.backtrace.should == "one\ntwo\nthree"
    end

    it "should normalize the controller request data" do
      LoggedException.should_receive(:normalize_request_data).with(@controller)
      @logged_exception = LoggedException.log(@controller, @exception)
    end

    it "should return an instance of the registered logger class" do
      @logged_exception = LoggedException.log(@controller, @exception)
      @logged_exception.should be_an_instance_of(LoggedException)
    end
  end
  
  it 'should return the group count' do 
    e = LoggedException.create( :group_id => "hash", :request => {})
    LoggedException.should_receive( :count ).with( :conditions => ["group_id = ?", 'hash'] ).and_return( 42 )
    e.group_count.should == 42
  end
  
  describe '#handle_notifications' do 
    before(:each) do 
      @logged_exception = LoggedException.create(:request => {})
      Tartarus.stub(:configuration).and_return({ 'notification_threshold' => 10, 'notification_address' => 'test@example.com', 'enabled' => true, "logger_class"=>"LoggedException" })
    end
    
    it 'should return and not deliver notification if there is no address present' do
      Tartarus.should_receive(:configuration).and_return({ 'enabled' => true, "logger_class"=>"LoggedException" })
      Tartarus::Notifiers::Mail.should_receive( :deliver_notification ).never

      @logged_exception.handle_notifications
    end

    it 'should send email if there is an address present and the count matches the threshold' do 
      Tartarus::Notifiers::Mail.should_receive( :deliver_notification ).with( 'test@example.com', @logged_exception )
      @logged_exception.stub( :group_count ).and_return( 20 )
      @logged_exception.handle_notifications
    end
    
    it 'should send email if there is an address present and it is the first exception in a group' do 
      Tartarus::Notifiers::Mail.should_receive( :deliver_notification ).with( 'test@example.com', @logged_exception )
      @logged_exception.stub( :group_count ).and_return( 1 )
      @logged_exception.handle_notifications
    end
    
    it 'should not send email if there is an address present and the count does not match the threshold' do 
      Tartarus::Notifiers::Mail.should_receive( :deliver_notification ).never
      @logged_exception.stub( :group_count ).and_return( 22 )
      @logged_exception.handle_notifications
    end
  end

  describe 'when normalizing request data for tartarus' do
    before(:each) do
      @mock_env = { 'action_controller.instance' => stub('controller_instance', :request => fake_controller_request) }
      @logged_exception = LoggedException.create(:request => {})
      Tartarus.stub(:configuration).and_return({ 'notification_threshold' => 10, 'notification_address' => 'test@example.com', 'enabled' => true, "logger_class"=>"LoggedException" })
    end

    it 'should have the session hash' do 
      params = LoggedException.normalize_request_data(@mock_env)
      params[:session].should_not be_blank
      params[:session].should be_an_instance_of(Hash)
      params[:session].should == { :cookie => {}, :variables => { :id=>"123123" } }
    end
 
    it 'should have a enviroment hash that contains a hash of only the uppercase keys of the original controller request hash' do
      params = LoggedException.normalize_request_data(@mock_env)
      params[:enviroment].should_not be_blank
      params[:enviroment].should == { "http_host" => "test_host", "loooooooong_key_two" => "key_two_value", "key_one" => "key_one_value", :server => `hostname -s`.chomp, :process => $$ }
    end
  
    it 'should have a http details hash' do
      params = LoggedException.normalize_request_data(@mock_env)
      params[:http_details].should_not be_blank
      params[:http_details].should == { :parameters => "params", :format => "html", :method => "POST", :url => "http://test_host/my/uri" }
    end

    it "should return a hash of request data" do
      params = LoggedException.normalize_request_data(@mock_env)
      params.should be_an_instance_of(Hash)
    end
  end

end
