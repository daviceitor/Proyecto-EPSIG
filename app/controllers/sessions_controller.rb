# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.erb.html
  def new
    if current_user
      redirect_to :controller => :accounts, :action => :index
    end
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password])
   
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      if !current_user.Admin? && current_user.can_go_to_home?
        redirect_back_or_default('/home')
      else
        redirect_back_or_default('/accounts')
      end
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      redirect_to "/login"
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
