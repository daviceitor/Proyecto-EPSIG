# To change this template, choose Tools | Templates
# and open the template in the editor.
class HomeController < ApplicationController

  def index

    case current_user.role.underscore
      when "project_manager"
        @last_offers_assign = Offer.find_all_by_responsable_id(current_user.id, :order => "id desc", :limit => 10)
      when "contabilidad"
        filter = {"full_billed" => "1", "full_charged" => "1", "state" => "Ganada"}
        billed_and_charged = Offer.filter_index(current_user, filter.clone, 1)
        @last_offers_pending_billed = (Offer.find_all_by_state("Ganada") - billed_and_charged).sort_by{|o| -o.id}.take(10)
      when "account_manager"
        @last_offers_pending = Offer.find(:all, :order => "id desc", :conditions => {:state => "Pendiente", :commercial_id => current_user.id}, :limit => 10)
    end
   
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end