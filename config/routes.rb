ActionController::Routing::Routes.draw do |map|
  
  map.resources :bills

  map.resources :versions, :member => {:download => :get}

  map.resources :offer_types

  map.resources :offers, :member => {:download => :get} do |offer|
    offer.resources :bills, :name_prefix => "offer_", :collection => {:edit_multiple => :get}
    offer.resources :versions, :name_prefix => "offer_"
  end
  
  map.resources :resources

  map.resources :operations, :collection => {:generate_csv => :get}

  map.resources :openkm

  map.resources :home

  map.resources :seats

  map.resources :contacts

  map.resources :accounts, :member => {:render_similars => :get} do |account|
    account.resources :contacts, :name_prefix => "account_"
    account.resources :seats, :name_prefix => "account_"
  end

  map.resources :search, :only => :index 

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.forgot '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.resources :users

  map.resource :session

  map.root :controller => 'sessions', :action => 'new'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end