require 'spec_helper'

describe OfferType do
  before(:each) do
    @valid_attributes = {
      :name => "WebTrends"
    }
  end

  it "should create a new instance given valid attributes" do
    OfferType.create!(@valid_attributes)
  end
end
