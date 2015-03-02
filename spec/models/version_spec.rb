require 'spec_helper'

describe Version do
  
  it "should create a new instance given valid attributes" do
    v = Factory.create :version
    v.save.should be_true
  end
  
  describe "Validate attributes" do
    
    it "should have a valid licences amount" do
      v = Factory.create :version
      v.licences_amount = "asdf"
      v.should have(1).errors_on(:licences_amount)
      v.licences_amount = -1
      v.should have(1).errors_on(:licences_amount)
    end

    it "should have a valid recurrent services amount" do
      v = Factory.create :version
      v.recurrent_services_amount = "asdf"
      v.should have(1).errors_on(:recurrent_services_amount)
      v.recurrent_services_amount = -1
      v.should have(1).errors_on(:recurrent_services_amount)
    end

    it "should have a valid no recurrent services amount" do
      v = Factory.create :version
      v.no_recurrent_services_amount = "asdf"
      v.should have(1).errors_on(:no_recurrent_services_amount)
      v.no_recurrent_services_amount = -1
      v.should have(1).errors_on(:no_recurrent_services_amount)
    end

    it "should have at least one amount" do
      v = Factory.build :version, :licences_amount => nil, :no_recurrent_services_amount => nil, :recurrent_services_amount => nil
      v.save.should be_false
      v.should have(1).errors
      v.licences_amount = 2
      v.save.should be_true
    end
    
  end

end
