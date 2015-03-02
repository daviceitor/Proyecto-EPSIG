# To change this template, choose Tools | Templates
# and open the template in the editor.
class OpenkmController < ApplicationController

  def index
       
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end