require File.dirname(__FILE__) + '/../spec_helper'

describe LoggedException do 
  it "should include the Tartarus::Logger module" do
    LoggedException.included_modules.include?(Tartarus::Logger)
  end
end
