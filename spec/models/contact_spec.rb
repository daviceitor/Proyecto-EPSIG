require 'spec_helper'

describe Contact do
  
  it "should create a new instance given valid attributes" do
    c = Factory.create :contact
    c.save.should be_true
  end

  it "should have a name" do
    contact = Factory.create :contact
    contact.name = nil
    contact.should have(1).errors_on(:name)
  end

  it "should have a valid lead_source" do
    contact = Factory.create :contact
    contact.lead_source = "Otra cosa"
    contact.should have(1).errors_on(:lead_source)
  end

  it "should have seat" do
    contact = Factory.create :contact
    contact.seat = nil
    contact.should have(1).errors_on(:seat)
  end

end
