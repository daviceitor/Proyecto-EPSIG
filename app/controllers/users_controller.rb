class UsersController < ApplicationController

  before_filter :manage_users_required, :except => [:edit,:update,:forgot_password]

  # render new.rhtml
  def new
    @user = User.new
  end

  def index
    @filter = params[:filter]

    if(@filter && @filter != "all")
      @users =  User.paginate_all_by_role @filter, :page => params[:page], :order => "name ASC"
    else
      @users = User.paginate :page => params[:page], :order => "name ASC"
    end

    respond_to do |format|
      if request.xhr?
        format.html { render :partial => 'list', :layout => false }
      else
        format.html
      end
      format.xml  { render :xml => @users }
    end
  end

  def edit
    unless current_user.can_manage_users? || current_user.can_change_pass?(params[:id].to_i)
      redirect_to accounts_path
    end
    @user = User.find(params[:id])
  end
 
  def create

    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      #self.current_user = @user # !! now logged in
      redirect_back_or_default('/users')
      flash[:notice] = "User create successfully."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def update
    @user = User.find(params[:id])
    
    valid_pass = !User.authenticate(params[:user][:email], params[:old_password]).nil? || current_user.can_manage_users?
    
    respond_to do |format|
      if @user.valid? and valid_pass and @user.update_attributes(params[:user])
        format.html { redirect_to(users_path, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def forgot_password
    @user = User.find_by_email(params[:email])

    if @user
      @user.password = @user.password_confirmation = new_pass = User.random_password(12)
      if @user.save
        Notifier.deliver_reset_password(@user, new_pass)
        flash[:notice] = "Se ha mandado un email con su nueva contraseña"
        redirect_to("/login")        
      end
    else
      @error = "el email introducido no existe" if params[:email]
    end
  end

end
