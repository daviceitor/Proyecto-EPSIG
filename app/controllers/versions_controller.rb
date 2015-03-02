class VersionsController < ApplicationController

  before_filter :login_required
  before_filter :can_download_version_required, :only => [:download]
  before_filter :can_create_version_required, :only => [:create]
  before_filter :can_edit_version_required, :only => [:edit,:update]
  before_filter :can_delete_version_required, :only => [:destroy]
  
  # GET /versions
  # GET /versions.xml
  def index
    @versions = Version.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @versions }
    end
  end

  # GET /versions/1
  # GET /versions/1.xml
  def show
    @version = Version.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @version }
    end
  end

  # GET /versions/new
  # GET /versions/new.xml
  def new
    @version = Version.new
    @version.offer = Offer.find(params[:offer_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @version }
    end
  end

  # GET /versions/1/edit
  def edit
    @version = Version.find(params[:id])
  end

  # POST /versions
  # POST /versions.xml
  def create

    amounts = ["licences","recurrent_services","no_recurrent_services"]
    amounts.each{|am| params[:version][am+"_amount"] = nil unless params[am] }
    
    @version = Version.new(params[:version])

    respond_to do |format|
      if @version.save        
        format.html { redirect_to(offers_path, :notice => 'Version was successfully created.') }
        format.xml  { render :xml => @version, :status => :created, :location => @version }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @version.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /versions/1
  # PUT /versions/1.xml
  def update
    @version = Version.find(params[:id])

    amounts = ["licences","recurrent_services","no_recurrent_services"]
    amounts.each{|am| params[:version][am+"_amount"] = nil unless params[am] }
    
    respond_to do |format|
      if @version.update_attributes(params[:version])
        format.html { redirect_to(@version.offer, :notice => 'Version was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @version.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /versions/1
  # DELETE /versions/1.xml
  def destroy
    @version = Version.find(params[:id])
    @version.destroy

    respond_to do |format|
      format.html { redirect_to(versions_url) }
      format.xml  { head :ok }
    end
  end

  def download
    @version = Version.find_by_id(params[:id])
    commercial = ""
    @version.offer.commercial.name.each(" ") {|s| commercial+= s.first}
    
    name = "#{@version.offer.account.name.gsub(" ","_")}_propuesta_#{commercial}_#{@version.offer_id}_#{@version.cod.to_i-1}"
    send_file "#{@version.doc.path}", :type => "#{@version.doc_content_type}", :filename => "#{name}#{File.extname @version.doc.original_filename}"
  end

end
