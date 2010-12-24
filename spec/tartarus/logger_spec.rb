require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tartarus::Logger do
  it 'should serialize the request attribute' do
    LoggedException.serialized_attributes.include?('request').should be_true
  end

  describe "#log" do
    before(:each) do
      LoggedException.stub!(:normalize_request_data).and_return({})
      @controller = mock('controller', :controller_path => 'home', :normalize_request_data_for_tartarus => 'params', :action_name => 'index', :request => fake_controller_request)
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
      @controller.should_receive(:normalize_request_data_for_tartarus)
      @logged_exception = LoggedException.log(@controller, @exception)
    end

    it "should return an instance of the registered logger class" do
      @logged_exception = LoggedException.log(@controller, @exception)
      @logged_exception.should be_an_instance_of(LoggedException)
    end
  end
  
  it 'should return the group count' do 
    e = LoggedException.create( :group_id => "hash" )
    LoggedException.should_receive( :count ).with( :conditions => ["group_id = ?", 'hash'] ).and_return( 42 )
    e.group_count.should == 42
  end
  
  describe '#handle_notifications' do 
    before(:each) do 
      @logged_exception = LoggedException.create
      Tartarus.configuration['notification_threshold'] = 10
      Tartarus.configuration['notification_address'] = 'test@example.com'
    end
    
    it 'should return and not deliver notification if there is no address present' do 
      Tartarus::Notifiers::Mail.should_receive( :deliver_notification ).never
      Tartarus.configuration['notification_address'] = nil

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

end
