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
      delete :destroy_all
    end
  end
  
  get "share/email_form" => "share#email_form"
  match "share/send_email"

  resources :needs do
    resources :offers, :only => [:create]
    collection do
      get :search
      get :map
    end
  end
  
  resources :need_categories, :except => [:show] do
    resources :needs, :only => [:new, :index]
    resources :general_offers, :only => [:index]
  end  
  
  resources :users, :only => []  do
    resources :needs, :only => :index
    resources :offers, :only => :index
    member do
      put :request_to_be_champion
      get :validate
      put :unvalidate
      put :assign_champion
      put :toggle_champion
      put :toggle_is_deleted
    end
    collection do
      get :map
    end
  end

  resource :champion, :only => :show

  resources :offers, :only => [:index, :create] do
    member do
      get :accept
      get :reject
    end
  end

  resources :general_offers, :except => [:index, :edit, :update] do
    member do
      get :thanks
      post :accept
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
      get 'all'
    end
    member do
      get :members, :join
    end
    resources :group_invitations, :path => 'invitations', :only => [:new, :create]
    resources :photos, :only => [:new, :create, :index, :show]
  end
  resources :group_invitations, :only => :show do
    resources :group_registrations, :path => 'registrations', :only => :new
  end
  resources :group_registrations, :path => 'groups/registrations', :only => [:new, :create]

  get '/r/:auth_token' => 'home#index', :as => 'auth_token'
  
  resources :neighbourhoods do
    member do
      get "email" => "neighbourhoods#new_email"
      post "email" => "neighbourhoods#create_email"
    end
  end
  
  get "neighbourhood" => "home#index"
  get "area/:id" => "neighbourhoods#show"
  get "neighbourhoods/:neighbourhood/posts" => "posts#index", :as => 'neighbourhood_posts'
  match "neighbourhoods/:neighbourhood/snippets" => "neighbourhoods#snippets", :as => 'neighbourhood_snippets'
  get "neighbourhoods/:neighbourhood/about" => "neighbourhoods#about", :as => 'neighbourhood_about'
  get 'neighbourhoods/:neighbourhood/news' => 'neighbourhoods#news', :as => 'neighbourhood_news'  
  get 'neighbourhoods/:neighbourhood/help' => 'neighbourhoods#help', :as => 'neighbourhood_help'  
  
  match "searches" => "searches#index", :as => "searches"

end
