require 'spec_helper'

describe Notifier do

    it "should send mail for notification offer win" do
      offer = Factory.create :offer
      Factory.create :version, :offer => offer
      user = Factory.create :user

      lambda {Notifier.deliver_offer_win_notification user,offer}.should change(ActionMailer::Base.deliveries,:size).by(1)
    end
 
    it "should send mail for notification responsable assign" do
      offer = Factory.create :offer
      Factory.create :version, :offer => offer
      user = Factory.create :user

      lambda {Notifier.deliver_responsable_notification user,offer}.should change(ActionMailer::Base.deliveries,:size).by(1)
    end
  
end
