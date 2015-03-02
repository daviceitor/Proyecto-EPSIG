class ResourcesController < ApplicationController
  
  before_filter :login_required
  before_filter :manage_resources_required, :only => [:edit,:update,:destroy]

  def index
    @resources = Resource.paginate :page => params[:page], :order => "name ASC"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resources }
    end
  end


  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resource }
    end
  end


  def new
    @resource = Resource.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource }
    end
  end


  def edit
    @resource = Resource.find(params[:id])
  end


  def create
    @resource = Resource.new(params[:resource])
    @resource.user = current_user
    
    respond_to do |format|
      if @resource.save
        format.html { redirect_to(resources_url, :notice => 'Resource was successfully created.') }
        format.xml  { render :xml => @resource, :status => :created, :location => @resource }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  def update
    @resource = Resource.find(params[:id])

    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        format.html { redirect_to(resources_url, :notice => 'Resource was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to(resources_url) }
      format.xml  { head :ok }
    end
  end
end
