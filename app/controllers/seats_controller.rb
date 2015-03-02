class SeatsController < ApplicationController

  include Ym4r::GoogleMaps

  before_filter :login_required
  before_filter :manage_crm_required, :except => [:index,:show]

  def index
    @seats = Seat.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @seats }
    end
  end
  
  def show
    @seat = Seat.find(params[:id])
    place = "#{@seat.postalcode}, #{@seat.state}, #{@seat.city}, #{@seat.street}"
    results = Geocoding::get(place)

    if results.status == Geocoding::GEO_SUCCESS
      @coord = results[0].latlon
    end
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @seat }
      end
    end


    def new
      @seat = Seat.new
      @account_id = params[:account_id]
    
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @seat }
      end
    end


    def edit
      @seat = Seat.find(params[:id])
    end


    def create
      @seat = Seat.new(params[:seat])
      @seat.create_contacts_hash(params[:method], params[:value])

      respond_to do |format|
        if @seat.save
          format.html { redirect_to(@seat, :notice => 'Seat was successfully created.') }
          format.xml  { render :xml => @seat, :status => :created, :location => @seat }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @seat.errors, :status => :unprocessable_entity }
        end
      end
    end


    def update
      @seat = Seat.find(params[:id])
      @seat.create_contacts_hash(params[:method], params[:value])

      respond_to do |format|
        if @seat.update_attributes(params[:seat])
          format.html { redirect_to(@seat, :notice => 'Seat was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @seat.errors, :status => :unprocessable_entity }
        end
      end
    end


    def destroy
      @seat = Seat.find(params[:id])
      @seat.destroy

      respond_to do |format|
        format.html { redirect_to(seats_url) }
        format.xml  { head :ok }
      end
    end
  end
