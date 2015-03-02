# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def get_accounts_for_select
    Account.all(:order => "name ASC").map { |a| [a.name,a.id] }
  end

  def current_class name
    if name == controller.controller_name
      "current"
    end
  end

end
