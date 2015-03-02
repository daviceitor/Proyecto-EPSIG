module ContactsHelper

  def get_seats_by_account_for_select account_id = nil
    if account_id.nil?
      account_id = Account.first(:order => "name asc").id
    end
    Seat.find_all_by_account_id(account_id, :order => "name asc").map { |s| [s.name,s.id] }
  end

end
