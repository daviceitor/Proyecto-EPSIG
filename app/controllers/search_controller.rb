class SearchController < ApplicationController

  before_filter :login_required
    
  def index   
    @results = ThinkingSphinx.search params[:search], :star => true, :page => params[:page], :per_page => 5

    respond_to do |format|
      #if request.xhr?
        format.html { render :partial => 'index', :layout => false }
      #else
      #  format.html
      #end
      format.xml  { render :xml => @results }
    end
  end
end
