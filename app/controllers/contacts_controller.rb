class ContactsController < ApplicationController
  
  before_filter :login_required
  before_filter :manage_crm_required, :except => [:index,:show]
  
  def index
    
    @filter = params[:filter]

    if(@filter && @filter != "all")
      @contacts =  Contact.paginate :joins => :seat, :conditions => ["seats.account_id = ?", @filter], :page => params[:page], :order => "name ASC"
    else
      @contacts = Contact.paginate :page => params[:page], :order => "name ASC"
    end

    respond_to do |format|
      if request.xhr?
        format.html { render :partial => 'list', :layout => false }
      else
        format.html
      end
      format.xml  { render :xml => @contacts }
    end
  end


  def show
    @contact = Contact.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact }
    end
  end


  def new
    @contact = Contact.new
    @account_id = params[:account_id]
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contact }
      format.json { render :json => Account.find(params[:account_id]).seats.sort{|a,b| a.name <=> b.name}.to_json }
    end
  end

 
  def edit    
    @contact = Contact.find(params[:id])
    
    respond_to do |format|
      format.html
      format.json { render :json => Account.find(params[:account_id]).seats.sort{|a,b| a.name <=> b.name}.to_json }
    end
  end


  def create
    @contact = Contact.new(params[:contact])
    @contact.create_contacts_hash(params[:method], params[:value])
    
    respond_to do |format|
      if @contact.save
        format.html { redirect_to(@contact, :notice => 'Contact was successfully created.') }
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @contact = Contact.find(params[:id])
    @contact.create_contacts_hash(params[:method], params[:value])
       
    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        format.html { redirect_to(@contact, :notice => 'Contact was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  def render_similars

    @similars = []
    @similars = Contact.similars(params[:filter][:name],params[:filter][:sur_name]) unless params[:filter].blank?

    respond_to do |format|
      if request.xhr?
        format.html { render :partial => 'similars', :layout => false, :locals => {:similars => @similars} }
      end
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to(contacts_url) }
      format.xml  { head :ok }
    end
  end
  
end
