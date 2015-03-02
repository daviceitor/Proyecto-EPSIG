require 'spec_helper'

describe Offer do

  it "should create a new instance given valid attributes" do
    o = Factory.new :offer
    o.save.should be_true
  end

  describe "Validate attributes" do
    it "should have associated account" do
      offer = Factory.build :offer, :account => nil
      offer.should have(1).errors_on(:account)
    end

    it "should have associated offer_type" do
      offer = Factory.create :offer
      offer.offer_type = nil
      offer.should have(1).errors_on(:offer_type)
    end

    it "should have creation day" do
      offer = Factory.create :offer
      offer.creation_day.should == Date.today
    end

    it "should have a state" do
      offer = Factory.create :offer
      offer.state = nil
      offer.should have(1).errors_on(:state)
    end

    it "should have a win probability between 0 and 100" do
      offer = Factory.create :offer
      offer.win_probability = "-1asf"
      offer.should have(1).errors_on(:win_probability)
      offer.win_probability = -1
      offer.should have(1).errors_on(:win_probability)
      offer.win_probability = 101
      offer.should have(1).errors_on(:win_probability)
    end

    it "should have a version index greater-equal 0" do
      offer = Factory.create :offer
      offer.actual_version_index = -1
      offer.should have(1).errors_on(:actual_version_index)
    end

    it "should have a approval doc and version doc on win" do
      offer = Factory.create :offer, :approved_doc_file_name => nil
      offer.Ganada!
      offer.should have(2).errors
    end

  end

  describe "Version management" do

    it "should have a initial version index" do
      offer = Factory.create :offer
      offer.actual_version_index.should be_equal 0
    end

    it "should update actual version to last version create" do
      offer = Factory.create :offer
      v1 = Factory.create :version, :offer => offer
      v2 = Factory.create :version, :offer => offer
      offer.reload
      offer.actual_version.should eql v2
    end
  end

  describe "offer states changes behavior" do

    it "on offer create initial state is Pendiente" do
      offer = Factory.create :offer
      offer.aasm_current_state.should == :Pendiente
    end

    it "insert comment on offer create" do
      offer = Factory.create :offer
      offer.comments.count.should eql 1
    end
    
    it "insert comment on offer change: Perdida" do
      offer = Factory.create :offer
      offer.Perdida!
      offer.comments.count.should eql 2
    end

    it "insert comment on offer change: Eliminada" do
      offer = Factory.create :offer
      offer.Eliminada!
      offer.comments.count.should eql 2
    end

    it "insert comment on offer change: Ganada" do
      offer = Factory.create :offer
      v1 = Factory.create :version, :offer => offer
      offer.Ganada!
      offer.comments.count.should eql 2
    end

    it "insert comment on offer change: Pendiente (again)" do
      offer = Factory.create :offer
      offer.Perdida!
      offer.Pendiente!
      offer.comments.count.should eql 3
    end

    it "send mail offer win notification on offer change: Ganada to Operation manager and contabilidad" do
      offer = Factory.create :offer
      Factory.create :version, :offer => offer
      u1 = Factory.create :user, :role => "Operation_manager"
      u2 = Factory.create :user, :role => "Operation_manager"
      u3 = Factory.create :user, :role => "Contabilidad"
      u4 = Factory.create :user, :role => "Project_manager"
      u5 = Factory.create :user, :role => "Guest"
      u6 = Factory.create :user, :role => "Crm_manager"
      u7 = Factory.create :user, :role => "Crm_reader"
      u8 = Factory.create :user, :role => "Admin"
      u9 = Factory.create :user, :role => "Account_manager"

      lambda { offer.Ganada! }.should change(ActionMailer::Base.deliveries,:size).by(3)
      
      emails = ActionMailer::Base.deliveries.map {|message| message['to'].to_s}
   
      emails.should include u1.email
      emails.should include u2.email
      emails.should include u3.email
      emails.should_not include u4.email
      emails.should_not include u5.email
      emails.should_not include u6.email
      emails.should_not include u7.email
      emails.should_not include u8.email
      emails.should_not include u9.email
    end
  end

  it "send mail notification on assign responsable to project manager" do
    offer = Factory.create :offer
    Factory.create :version, :offer => offer
    u1 = Factory.create :user, :role => "Operation_manager"
    u2 = Factory.create :user, :role => "Contabilidad"
    u3 = Factory.create :user, :role => "Project_manager"
    u4 = Factory.create :user, :role => "Project_manager"
    u5 = Factory.create :user, :role => "Project_manager"
    u6 = Factory.create :user, :role => "Guest"
    u7 = Factory.create :user, :role => "Crm_manager"
    u8 = Factory.create :user, :role => "Crm_reader"
    u9 = Factory.create :user, :role => "Admin"
    u10 = Factory.create :user, :role => "Account_manager"

    offer.responsable = u4

    lambda { offer.save! }.should change(ActionMailer::Base.deliveries,:size).by(1)

    emails = ActionMailer::Base.deliveries.map {|message| message['to'].to_s}

    emails.should include u4.email
    emails.should_not include u1.email
    emails.should_not include u2.email
    emails.should_not include u3.email
    emails.should_not include u5.email
    emails.should_not include u6.email
    emails.should_not include u7.email
    emails.should_not include u8.email
    emails.should_not include u9.email
    emails.should_not include u10.email
  end

  describe "filters behavior" do
    it "should not index deleted offers" do
      offer = Factory.create :offer, :state => "Eliminada"
      Factory.create :version, :offer => offer
      u = Factory.create :user, :role => "Admin"

      filter={}
      Offer.filter_index(u, filter, 1).should be_empty
    end

    it "should index only assign offers to project managers" do
      u = Factory.create :user, :role => "Project_manager"
      offer = Factory.create :offer, :state => "Ganada", :responsable => u
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer, :state => "Ganada"      
      Factory.create :version, :offer => offer2
      
      filter={}
      Offer.filter_index(u, filter, 1).length.should == 1
      Offer.filter_index(u, filter, 1).first.should == offer
    end

    it "should filter by state" do
      offer = Factory.create :offer, :state => "Ganada"
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer, :state => "Perdida"
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer, :state => "Pendiente"
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer, :state => "Eliminada"
      Factory.create :version, :offer => offer4

      u = Factory.create :user, :role => "Admin"

      filter = {:state => "Ganada"}
      Offer.filter_index(u, filter, 1).length.should == 1
      Offer.filter_index(u, filter, 1).first.should == offer
    end

    it "should filter by account" do
      a = Factory.create :account
      offer = Factory.create :offer, :state => "Ganada"
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer, :state => "Perdida", :account_id => a.id
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer, :state => "Pendiente"
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer, :state => "Eliminada"
      Factory.create :version, :offer => offer4

      u = Factory.create :user, :role => "Admin"

      filter = {:account_id => "#{a.id}"}
      Offer.filter_index(u, filter, 1).length.should == 1
      Offer.filter_index(u, filter, 1).first.should == offer2
    end

    it "should filter by id" do
      offer = Factory.create :offer, :state => "Ganada"
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer, :state => "Perdida"
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer, :state => "Pendiente"
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer, :state => "Eliminada"
      Factory.create :version, :offer => offer4

      u = Factory.create :user, :role => "Admin"

      filter = {:id => "#{offer3.id}"}
      Offer.filter_index(u, filter, 1).length.should == 1
      Offer.filter_index(u, filter, 1).first.should == offer3
    end

    it "should filter by commercial" do
      c = Factory.create :user, :role => "Account_manager"
      offer = Factory.create :offer, :state => "Ganada"
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer, :state => "Perdida"
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer, :state => "Pendiente", :commercial_id => c.id
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer, :state => "Eliminada"
      Factory.create :version, :offer => offer4

      u = Factory.create :user, :role => "Admin"

      filter = {:commercial_id => "#{c.id}"}
      Offer.filter_index(u, filter, 1).length.should == 1
      Offer.filter_index(u, filter, 1).first.should == offer3
    end

    it "should filter by offer type" do
      ot= Factory.create :offer_type
      offer = Factory.create :offer, :state => "Ganada", :offer_type_id => ot.id
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer, :state => "Perdida"
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer, :state => "Pendiente"
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer, :state => "Eliminada"
      Factory.create :version, :offer => offer4

      u = Factory.create :user, :role => "Admin"

      filter = {:offer_type_id => "#{ot.id}"}
      Offer.filter_index(u, filter, 1).length.should == 1
      Offer.filter_index(u, filter, 1).first.should == offer
    end

    it "should filter by billed state: not billed" do
      offer = Factory.create :offer
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer
      Factory.create :version, :offer => offer4

      b = Factory.create :bill, :offer => offer4
      b = Factory.create :bill, :offer => offer2
      u = Factory.create :user, :role => "Admin"

      offer4.full_billed = true
      offer4.save!

      filter = {"full_billed" => "0"}
      Offer.filter_index(u, filter.clone, 1).length.should == 2
      Offer.filter_index(u, filter.clone, 1).should include offer
      Offer.filter_index(u, filter.clone, 1).should_not include offer2
      Offer.filter_index(u, filter.clone, 1).should include offer3
      Offer.filter_index(u, filter.clone, 1).should_not include offer4
    end

    it "should filter by billed state: partially billed" do
      offer = Factory.create :offer
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer
      Factory.create :version, :offer => offer4

      b = Factory.create :bill, :offer => offer4
      b = Factory.create :bill, :offer => offer2
      u = Factory.create :user, :role => "Admin"
      
      offer4.full_billed = true
      offer4.save!

      filter = {"full_billed" => "2"}
      Offer.filter_index(u, filter.clone, 1).length.should == 1
      Offer.filter_index(u, filter.clone, 1).should_not include offer
      Offer.filter_index(u, filter.clone, 1).should include offer2
      Offer.filter_index(u, filter.clone, 1).should_not include offer3
      Offer.filter_index(u, filter.clone, 1).should_not include offer4
    end

    it "should filter by billed state: full billed" do
      offer = Factory.create :offer
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer
      Factory.create :version, :offer => offer4

      b = Factory.create :bill, :offer => offer
      b = Factory.create :bill, :offer => offer2
      u = Factory.create :user, :role => "Admin"

      offer.full_billed = true
      offer.save!

      filter = {"full_billed" => "1"}
      Offer.filter_index(u, filter.clone, 1).length.should == 1
      Offer.filter_index(u, filter.clone, 1).should include offer
      Offer.filter_index(u, filter.clone, 1).should_not include offer2
      Offer.filter_index(u, filter.clone, 1).should_not include offer3
      Offer.filter_index(u, filter.clone, 1).should_not include offer4
    end

    it "should filter by charged state: not charged" do
      offer = Factory.create :offer
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer
      Factory.create :version, :offer => offer4

      b = Factory.create :bill, :offer => offer4, :cod => "1"
      b2 = Factory.create :bill, :offer => offer2, :cod => "2"
      u = Factory.create :user, :role => "Admin"

      b.charged = true
      b.save!

      filter = {"full_charged" => "0"}
      Offer.filter_index(u, filter.clone, 1).length.should == 1
      Offer.filter_index(u, filter.clone, 1).should_not include offer
      Offer.filter_index(u, filter.clone, 1).should include offer2
      Offer.filter_index(u, filter.clone, 1).should_not include offer3
      Offer.filter_index(u, filter.clone, 1).should_not include offer4
    end

    it "should filter by charged state: partially charged" do
      offer = Factory.create :offer
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer
      Factory.create :version, :offer => offer4

      b = Factory.create :bill, :offer => offer, :cod => "1"
      b2 = Factory.create :bill, :offer => offer, :cod => "2"
      b3 = Factory.create :bill, :offer => offer2, :cod => "3"
      u = Factory.create :user, :role => "Admin"

      b3.charged = true
      b3.save!
      b.charged = true
      b.save!
      
      filter = {"full_charged" => "2"}
      Offer.filter_index(u, filter.clone, 1).length.should == 1
      Offer.filter_index(u, filter.clone, 1).should include offer
      Offer.filter_index(u, filter.clone, 1).should_not include offer2
      Offer.filter_index(u, filter.clone, 1).should_not include offer3
      Offer.filter_index(u, filter.clone, 1).should_not include offer4
    end

    it "should filter by charged state: full charged" do
      offer = Factory.create :offer
      Factory.create :version, :offer => offer
      offer2 = Factory.create :offer
      Factory.create :version, :offer => offer2
      offer3 = Factory.create :offer
      Factory.create :version, :offer => offer3
      offer4 = Factory.create :offer
      Factory.create :version, :offer => offer4

      b = Factory.create :bill, :offer => offer, :cod => "1"
      b2 = Factory.create :bill, :offer => offer, :cod => "2"
      b3 = Factory.create :bill, :offer => offer2, :cod => "3"
      u = Factory.create :user, :role => "Admin"

      b3.charged = true
      b3.save!
      b.charged = true
      b.save!

      filter = {"full_charged" => "1"}
      Offer.filter_index(u, filter.clone, 1).length.should == 1
      Offer.filter_index(u, filter.clone, 1).should_not include offer
      Offer.filter_index(u, filter.clone, 1).should include offer2
      Offer.filter_index(u, filter.clone, 1).should_not include offer3
      Offer.filter_index(u, filter.clone, 1).should_not include offer4
    end
    
  end

end
