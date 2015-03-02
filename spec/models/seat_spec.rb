require 'spec_helper'

describe Seat do
  
  it "should create a new instance given valid attributes" do
    s = Factory.create :seat
    s.save.should be_true
  end

  it "should have a name" do
    seat = Factory.create :seat
    seat.name = nil
    seat.should have(1).errors_on(:name)
  end

  it "should have a street" do
    seat = Factory.create :seat
    seat.street = nil
    seat.should have(1).errors_on(:street)
  end

  it "should have a account" do
    seat = Factory.create :seat
    seat.account = nil
    seat.should have(1).errors_on(:account)
  end

end
