require 'spec_helper'

describe Account do

  it "should create a new instance given valid attributes" do
    account = Factory.create :account
    account.save.should be_true
  end

  describe "validate attributtes" do
    it "should have a name" do
      account = Factory.create :account
      account.name = nil
      account.should have(1).errors_on(:name)
    end

    it "should have a valid industry type" do
      account = Factory.create :account
      account.industry_type = "otra cosa"
      account.should have(1).errors_on(:industry_type)
    end

   it "should have a valid account type" do
      account = Factory.create :account
      account.account_type = "otra cosa"
      account.should have(1).errors_on(:account_type)
    end

    it "should have a unique name" do
      Factory.create :account, :name => "nombre"
      lambda {Factory.create :account, :name => "nombre"}.should raise_error
    end
  end

  it "should create a virtual seat after create a new account" do
    account = Factory.create :account
    account.seats.count.should be_equal 1
  end
end
