require 'spec_helper'

describe Resource do
  
  it "should create a new instance given valid attributes" do
    resource = Factory.create :resource
    resource.save.should be_true
  end
end
