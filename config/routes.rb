Mjolk::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  match 'posts/all' => 'posts#index'
  match 'posts/add' => 'posts#create', :via => :post
  match 'posts/delete' => 'posts#destroy', :via => :post
  match 'posts/edit' => 'posts#edit'
  match 'posts/update' => 'posts#update'
  match 'posts/import' => 'posts#import'
  match 'posts/import_url' => 'posts#import_url'
  match 'posts/import_file' => 'posts#import_file'
  resources :bookmarks, :controller => "posts"

  # tags
  match 'tags/' => 'tags#index', :via => :get

  # stats
  match 'stats/' => 'stats#index', :via => :get
  match 'stats/stats.json' => 'stats#stats', :via => :get, :format => :json

  # api
  match 'v1/posts/all' => 'v1/posts#index'
  match 'v1/posts/get' => 'v1/posts#get'
  match 'v1/posts/add' => 'v1/posts#create', :via => :post
  match 'v1/posts/delete' => 'v1/posts#destroy', :via => :post
  match 'v1/posts/update' => 'v1/posts#update'

  # admin
  match 'admin/users/mass_mail' => 'admin/users#mass_mail', :via => :get
  match 'admin/users/mass_email_send' => 'admin/users#mass_email_send', :via => :post
  scope 'admin', :as => "admin" do
    resources :users, :controller => "admin/users"
  end

  # 
  resources :posts

  root :to => "application#index"

end
