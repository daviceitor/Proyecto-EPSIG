class OffersController < ApplicationController

  before_filter :login_required
  before_filter :can_view_offer_required, :only => [:show,:download]
  before_filter :can_index_offers_required, :only => [:index]
  before_filter :can_create_offer_required, :only => [:new,:create]
  before_filter :can_edit_offer_required, :only => [:edit,:update]
  before_filter :can_delete_offer_required, :only => [:destroy]

  # GET /offers
  # GET /offers.xml
  def index
   
    @filter = params[:filter]? params[:filter] : {}
    @last_id = Offer.last.id
    
    @offers = Offer.filter_index(current_user, @filter.clone, params[:page])
     
    respond_to do |format|
      format.html
      format.xml  { render :xml => @offers }
    end
  end

  # GET /offers/1
  # GET /offers/1.xml
  def show
    @offer = Offer.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @offer }
    end
  end

  # GET /offers/new
  # GET /offers/new.xml
  def new
    @offer = Offer.new
    @version = Version.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @offer }
    end
  end

  # GET /offers/1/edit
  def edit
    @offer = Offer.find(params[:id])
    
  end

  # POST /offers
  # POST /offers.xml
  def create
    
    #change date format
    if !params[:offer][:estimated_date_resolution].empty?
      params[:offer][:estimated_date_resolution] = Date.strptime(params[:offer][:estimated_date_resolution],"%d/%m/%Y")
    end
        
    params[:offer][:commercial_id] = current_user.id  unless current_user.Operation_manager?

    amounts = ["licences","recurrent_services","no_recurrent_services"]
    amounts.each{|am| params[:version][am+"_amount"] = nil unless params[am] }
    
    @offer = Offer.new(params[:offer])
    @version = Version.new(params[:version])

    respond_to do |format|
      #save offer
      if @offer.valid? and @version.valid?
        @offer.save
        @offer.versions << @version
        format.html { redirect_to(@offer, :notice => 'Offer was successfully created.') }
        format.xml  { render :xml => @offer, :status => :created, :location => @offer }    
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /offers/1
  # PUT /offers/1.xml
  def update
    @offer = Offer.find(params[:id])
    attrs = params[:offer]
    
    #change date format
    if attrs[:estimated_date_resolution] and !attrs[:estimated_date_resolution].empty?
      attrs[:estimated_date_resolution] = Date.strptime(attrs[:estimated_date_resolution],"%d/%m/%Y")
    end

    if attrs[:state] && attrs[:state] != "Ganada"
      invalid_attr = [:approved_doc, :responsable_id]
      invalid_attr.each do |ia|
        attrs[ia] = nil
      end
    end
    
    @offer.attributes=attrs

    #make transition on state machine
    if @offer.state and @offer.state != @offer.state_was and @offer.valid?
      @offer.state = @offer.state_was
      @offer.send(attrs[:state].to_sym)
    end

    respond_to do |format|
      if @offer.update_attributes(attrs)         
        #render view
        format.html { redirect_to(@offer, :notice => 'Offer was successfully updated.') }
        format.json { render :json => @offer, :status => :ok }        
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /offers/1
  # DELETE /offers/1.xml
  def destroy
    @offer = Offer.find(params[:id])
    @offer.Eliminada!

    respond_to do |format|
      format.html { redirect_to(offers_url) }
      format.xml  { head :ok }
    end
  end

  def add_comment

    comment = params[:filter]
    
    @offer = Offer.find(comment[:id].to_i)
    @offer.comments.create(:comment => comment[:text], :user => current_user)

    respond_to do |format|
      format.html { render :partial => 'comments', :layout => false }
    end
  end

  def render_comments

    @offer = Offer.find(params[:filter].to_i)

    respond_to do |format|
      format.html { render :partial => 'comments', :layout => false }
    end
  end

  def download
    @offer = Offer.find_by_id(params[:id])
    commercial = ""
    @offer.commercial.name.each(" ") {|s| commercial+= s.first}

    name = "#{@offer.account.name}_aprobacion_#{commercial}_#{@offer.actual_version.version_cod}"
    send_file "#{@offer.approved_doc.path}", :type => "#{@offer.approved_doc_content_type}", :filename => "#{name}#{File.extname @offer.approved_doc.original_filename}"
  end

end
