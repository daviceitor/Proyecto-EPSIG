# To change this template, choose Tools | Templates
# and open the template in the editor.
class OperationsController < ApplicationController

  def index
    t = TicketingReport.new()
    @responsables = t.get_all_responsables
    @estados = t.get_states
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @responsables }
    end
  end

  def generate_csv
    ticketing = TicketingReport.new()
    ticketing.generate_report params[:idUsuario], params[:idEstado], params[:inicio], params[:fin]

    send_data ticketing.to_csv(params[:idUsuario], params[:idEstado], params[:inicio], params[:fin]), :filename => "operaciones.csv", :type => :csv
  end

end