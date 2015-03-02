class BillsController < ApplicationController

  before_filter :login_required
  before_filter :view_bills_required, :only => [:edit_multiple,:show]
  before_filter :manage_bills_required, :only => [:create,:delete,:update]

  # GET /bills
  # GET /bills.xml
  def index
    @bills = Bills.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bills }
    end
  end

  # GET /bills/1
  # GET /bills/1.xml
  def show
    @bill = Bill.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bill }
    end
  end

  # GET /bills/new
  # GET /bills/new.xml
  def new
    @bill = Bill.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bill }
    end
  end

  # GET /bills/1/edit
  def edit
    @bill = Bill.find(params[:id])
  end

  # GET /bills/1/edit
  def edit_multiple
    @offer = Offer.find(params[:offer_id])
    @bills = @offer.bills

    respond_to do |format|
      format.html
    end
  end

  # POST /bills
  # POST /bills.xml
  def create
    @offer = Offer.find(params[:filter])
    @bill = @offer.bills.create()
    respond_to do |format|
      if @bill
        format.html { render :template => "bills/edit", :layout => false}
      end
    end
  end

  # PUT /bills/1
  # PUT /bills/1.xml
  def update
    @bill = Bill.find(params[:id])

    respond_to do |format|
      if @bill.update_attributes(params[:bill])
        format.html { redirect_to(@bill, :notice => 'Bill was successfully updated.') }
        format.xml  { head :ok }
        format.json { render :json => @bill, :status => :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bill.errors, :status => :unprocessable_entity }
        format.json { render :json => @bill, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bills/1
  # DELETE /bills/1.xml
  def destroy
    @bill = Bill.find(params[:id])
    offer = @bill.offer
    @bill.destroy

    respond_to do |format|
      format.html { redirect_to(offer) }
      format.xml  { head :ok }
    end
  end
end
