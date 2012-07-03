Neighbours::Application.routes.draw do
  
  root :to => 'home#index'
  resources :wireframes, :only => [:index, :show]
  resources :registrations, :only => [:new, :create]  
  match "registrations/where_you_live" => "registrations#new", :step => "where_you_live", :as => "where_you_live_registration"
  
  resources :needs do
    resources :offers, :only => [:create]
    collection do
      get :search
    end
  end
  
  resources :need_categories, :except => [:show]
  
  resources :users, :only => []  do
    resources :needs, :only => :index 
    resources :offers, :only => :index 
    member do
      put :validate
    end
  end
  
  resources :offers, :only => :index do
    member do
      get :accept
      get :reject
    end
  end
  
  match "admin" => "users#index", :as => :admin
  
end
