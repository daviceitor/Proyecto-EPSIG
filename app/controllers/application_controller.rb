# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  #USERS FILTER

  def manage_users_required
    unless current_user.can_manage_users?
      redirect_back_or_default accounts_path
    end    
  end

  #CRM FILTER

  def manage_crm_required
    unless current_user.can_manage_crm?
      redirect_back_or_default accounts_path
    end
  end

  #RESOURCES FILTER

  def manage_resources_required
    unless current_user.can_manage_resource?(Resource.find(params[:id].to_i))
      redirect_back_or_default resources_path
    end
  end

  #OFFERS FILTERS

  def can_index_offers_required
    unless current_user.can_index_offers?
      redirect_back_or_default accounts_path
    end
  end

  def can_view_offer_required
    unless current_user.can_view_offer? Offer.find(params[:id].to_i)
      redirect_back_or_default offers_path
    end
  end

  def can_create_offer_required
    unless current_user.can_create_offer?
      redirect_back_or_default offers_path
    end
  end

  def can_edit_offer_required
 
    if current_user.can_edit_offer_bills_data? && !params[:offer].nil? && !current_user.Admin?
      #restricted to edit intermediary, full_billed and order_cod
      only =["intermediary_id", "full_billed", "order_cod"]
      params[:offer].each do |key,value|
        params[:offer].delete(key) if((!only.include?(key)) || value.blank?)
      end
    end

    unless current_user.can_edit_offer?(Offer.find(params[:id].to_i)) || current_user.can_edit_offer_bills_data?
      redirect_back_or_default offers_path
    end
  end

  def can_delete_offer_required
    unless current_user.can_delete_offer? Offer.find(params[:id].to_i)
      redirect_back_or_default offers_path
    end
  end

  #VERSIONS FILTERS

  def can_download_version_required
    unless current_user.can_download_version? Version.find(params[:id].to_i)
      redirect_back_or_default offers_path
    end
  end

  def can_create_version_required
    unless current_user.can_create_version? Offer.find(params[:version][:offer_id].to_i)
      redirect_back_or_default offers_path
    end
  end

  def can_edit_version_required
    unless current_user.can_edit_version? Version.find(params[:id].to_i)
      redirect_back_or_default offers_path
    end
  end

  def can_delete_version_required
    unless current_user.can_delete_version? Version.find(params[:id].to_i)
      redirect_back_or_default offers_path
    end
  end

  #BILLS FILTERS

  def view_bills_required
    unless current_user.can_view_bills?
      redirect_back_or_default offers_path
    end
  end

  def manage_bills_required
    unless current_user.can_manage_bills?
      redirect_back_or_default offers_path
    end
  end

  class Helper
    include Singleton
    include ContactsHelper
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
