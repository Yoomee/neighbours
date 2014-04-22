Neighbours::Application.routes.draw do

  root :to => 'home#index'

  match 'feedback' => 'enquiries#new', :id => 'feedback'
  match 'other-neighbourhoods' => 'enquiries#new', :id => 'other_neighbourhood', :as => "other_neighbourhood"
  get 'about' => 'neighbourhoods#about'

  resources :registrations, :only => :new
  match "registrations(/:step)" => "registrations#create", :via => [:post, :put], :as => 'registrations'
  match "registrations/who_you_are" => "registrations#new", :step => "who_you_are", :as => "who_you_are_registration", :via => :get
  match "registrations/where_you_live" => "registrations#new", :step => "where_you_live", :as => "where_you_live_registration", :via => :get
  match "registrations/validate" => "registrations#new", :step => "validate", :as => "validate_registration"
 
  resources :pre_registrations, :path => 'pr' do
    collection do
      get :map
      get :about
      delete :destroy_all
    end
    member do
      put :update_role
    end
  end
  
  get "share/email_form" => "share#email_form"
  match "share/send_email"

  resources :needs do
    resources :offers, :only => [:create]
    collection do
      get :search
      get :map
      put :remove_all
      delete :destroy_all
    end
    member do
      get :remove
    end
  end
  
  resources :need_categories, :except => [:show] do
    resources :needs, :only => [:new, :index]
    resources :general_offers, :only => [:index]
  end  
  
  resources :users, :only => []  do
    resources :needs, :only => :index
    resources :offers, :only => :index
    resource :champion, :only => :show
    member do
      put :request_to_be_champion
      get :validate
      put :unvalidate
      put :assign_champion
      put :toggle_champion
      put :toggle_is_deleted
      put :send_activation_code
    end
    collection do
      get :inactive
      get :map
      get :search
    end
  end

  resource :champion, :only => :show

  resources :offers, :only => [:index, :create, :destroy] do
    collection do
      put :remove_all
      delete :destroy_all
    end
    member do
      get :accept
      get :reject
      get :remove
    end
  end

  resources :general_offers, :except => [:edit, :update] do
    member do
      get :thanks
      post :accept
    end
    collection do
      put :remove_all
      delete :destroy_all
    end
  end

  resources :flags, :only => [:create, :index] do
    member do
      put :resolve
    end
  end

  resources :communities, :only => [] do
    resources :posts, :only => :index
  end
  
  resources :groups do
    collection do
      get :list, :popular
    end
    member do
      get :members, :join
      delete :delete
    end
    resources :group_invitations, :path => 'invitations', :only => [:new, :create]
    resources :group_requests, :path => 'requests', :only => [:create, :index]
    resources :photos, :only => [:new, :create, :index, :show]
  end
  get 'groups/:id/posts/:post_id' => 'groups#show', :as => 'group_post'
  resources :group_invitations, :only => :show do
    resources :group_registrations, :path => 'registrations', :only => :new
  end
  get 'group_invitations/:id/:ref' => 'group_invitations#show', :as => 'group_invitation_ref'
  resources :group_registrations, :path => 'groups/registrations', :only => [:new, :create]
  resources :group_requests, :only => [:destroy] do
    member do
      put :accept
    end
  end

  get '/r/:auth_token' => 'registrations#new', :as => 'auth_token'
  get '/g/:auth_token' => 'group_registrations#new', :as => 'group_auth_token'
  
  resources :neighbourhoods do
    member do
      get :stats
    end
    collection do
      get :stats, :action => 'all_stats'
    end
  end

  resources :organisations
  
  get "neighbourhoods/:neighbourhood_id/emails/:role/new" => "neighbourhood_emails#new", :as => 'email_neighbourhood'
  post "neighbourhoods/:neighbourhood_id/emails/:role" => "neighbourhood_emails#create", :as => 'create_email_neighbourhood'
  
  get "neighbourhood" => "home#index"
  get "area/:id" => "neighbourhoods#show"
  get "neighbourhoods/:neighbourhood/posts" => "posts#index", :as => 'neighbourhood_posts'
  match "neighbourhoods/:neighbourhood/snippets" => "neighbourhoods#snippets", :as => 'neighbourhood_snippets'
  get "neighbourhoods/:neighbourhood/about" => "neighbourhoods#about", :as => 'neighbourhood_about'
  get 'neighbourhoods/:neighbourhood/news' => 'neighbourhoods#news', :as => 'neighbourhood_news'  
  get 'neighbourhoods/:neighbourhood/help' => 'neighbourhoods#help', :as => 'neighbourhood_help'  
  
  match "searches" => "searches#index", :as => "searches"

end
