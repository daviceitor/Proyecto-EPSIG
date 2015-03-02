require 'spec_helper'

describe Bill do

  it "should create a new instance given valid attributes" do
    b = Factory.build :bill
    b.save.should be_true
  end

  it "on create bill should not be charged" do
    b = Factory.create :bill
    b.charged.should be_false
  end

  it "should have a cod on update" do
    b = Factory.create :bill
    b.save.should be_false
    b.cod="1"
    b.save.should be_true;
  end

  it "should update charged date on update" do
    b = Factory.create :bill, :cod => "a"
    b.charged = 1
    b.save
    b.charged_date.should eql Date.today

    b.charged = 0
    b.save
    b.charged_date.should be_nil
  end

  it "should not create new bill if offer is full billed" do
    o = Factory.create :offer
    o.full_billed = 1
    lambda {Factory.create :bill, :offer => o}.should raise_error
  end

end
