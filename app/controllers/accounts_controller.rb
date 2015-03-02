class AccountsController < ApplicationController

  before_filter :login_required
  before_filter :manage_crm_required, :except => [:index,:show]
  
  def index
    @filter = params[:filter]

    if(@filter && @filter != "all")
      @accounts =  Account.paginate_all_by_industry_type @filter, :page => params[:page], :order => "name ASC"
    else
      @accounts = Account.paginate :page => params[:page], :order => "name ASC"
    end

    respond_to do |format|
      if request.xhr?
        format.html { render :partial => 'list', :layout => false }
      else
        format.html
      end      
      format.xml  { render :xml => @accounts }
    end
  end


  def show
    @account = Account.find(params[:id])
    conditions = {:account_id => @account.id}
    
    unless current_user.can_index_all_offers?
      conditions[:responsable_id] = current_user.id
    end

    @offers = Offer.paginate :page => params[:page], :conditions => conditions, :order => "id DESC"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end


  def new
    @account = Account.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end


  def edit
    @account = Account.find(params[:id])
  end


  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        format.html { redirect_to(@account, :notice => 'Account was successfully created.') }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to(@account, :notice => 'Account was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  def render_similars

    @similars = []
    @similars = Account.similars(params[:filter]) unless params[:filter].blank?

    respond_to do |format|
      if request.xhr?
        format.html { render :partial => 'similars', :layout => false, :locals => {:similars => @similars} }
      end
    end
  end
  
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end

end
