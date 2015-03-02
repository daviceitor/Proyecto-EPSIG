module OffersHelper

  def get_offer_types_for_select
    OfferType.all(:order => "name ASC").map { |ot| [ot.name,ot.id] }
  end

  def get_account_manager_for_select
    User.find_all_by_role("Account_manager", :order => "name ASC").map { |u| [u.name,u.id] }
  end

  def get_project_managers_for_select
    User.find_all_by_role("Project_manager", :order => "name ASC").map { |u| [u.name,u.id] }
  end

  def valid_states offer
    if current_user.Operation_manager? || offer.responsable.nil?
      valid_states = ["Pendiente", "Ganada", "Perdida"]
    else
      valid_states = ["Ganada"]
    end
  end

  def get_billed_filter_for_select
    [["Sin facturar","0"], ["Parcialmente","2"], ["Totalmente","1"]]
  end

  def get_charged_filter_for_select
    [["Sin cobrar","0"], ["Parcialmente","2"], ["Totalmente","1"]]
  end

end
