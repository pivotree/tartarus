require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class TartarusRescueTestController < ApplicationController
end

describe Tartarus::Rescue do
  before(:each) do
    @controller = TartarusRescueTestController.new
  end

  describe 'when mixed into another class' do
    it 'should alias_method_chain rescue_action method with tartarus' do
      @controller.should respond_to(:rescue_action_with_tartarus)
      @controller.should respond_to(:rescue_action_without_tartarus)
    end
  end

  describe 'when normalizing request data for tartarus' do
    before( :each ) do 
      @controller.stub( :request ).and_return( fake_controller_request )
    end

    it 'should have the session hash' do 
      params = @controller.normalize_request_data_for_tartarus
      params[:session].should_not be_blank
      params[:session].should be_an_instance_of(Hash)
      params[:session].should == { :cookie => {}, :variables => { :id=>"123123" } }
    end
 
    it 'should have a enviroment hash that contains a hash of only the uppercase keys of the original controller request hash' do
      params = @controller.normalize_request_data_for_tartarus
      params[:enviroment].should_not be_blank
      params[:enviroment].should == { "http_host" => "test_host", "loooooooong_key_two" => "key_two_value", "key_one" => "key_one_value", :server => `hostname -s`.chomp, :process => $$ }
    end
  
    it 'should have a http details hash' do
      params = @controller.normalize_request_data_for_tartarus
      params[:http_details].should_not be_blank
      params[:http_details].should == { :parameters => "params", :format => "html", :method => "POST", :url => "http://test_host/my/uri" }
    end

    it "should return a hash of request data" do
      params = @controller.normalize_request_data_for_tartarus
      params.should be_an_instance_of(Hash)
    end
  end

  describe "#rescue_action_with_tartarus" do
    before(:each) do
      @exception = StandardError.new
      @controller.stub!(:rescue_action_without_tartarus)
      @controller.stub!(:response_code_for_rescue).and_return(:internal_server_error)
      Tartarus.stub!(:logging_enabled?).and_return(true)
      Tartarus.stub!(:log)
    end

    it 'should log the exception with tartarus if the exception code should be an internal server error' do
      Tartarus.should_receive(:log).with(@controller, @exception)
      @controller.should_receive(:response_code_for_rescue).and_return(:internal_server_error)
      @controller.rescue_action_with_tartarus(@exception)
    end

    it 'should not log the exception with tartarus if the exception code is not an internal server error' do
      @controller.should_receive(:response_code_for_rescue).and_return(:not_found)
      @controller.rescue_action_with_tartarus(@exception)
    end

    it 'should log the exception with tartarus if exception logging is enabled' do
      Tartarus.should_receive(:logging_enabled?).and_return(true)
      @controller.rescue_action_with_tartarus(@exception)
    end

    it 'should not log the exception with tartarus if exception logging is disabled' do
      Tartarus.should_receive(:logging_enabled?).and_return(false)
      Tartarus.should_receive(:log).never

      @controller.rescue_action_with_tartarus(@exception)
    end

    it 'should invoke rescue_action_without_tartarus' do
      @controller.should_receive(:rescue_action_without_tartarus)
      @controller.rescue_action_with_tartarus(@exception)
    end
  end
end

