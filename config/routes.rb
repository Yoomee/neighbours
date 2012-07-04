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
  
  resource :neighbourhood, :only => :show

  resources :need_categories, :except => [:show] do
    resources :needs, :only => :new
  end
  
  resources :users, :only => []  do
    resources :needs, :only => :index 
    resources :offers, :only => :index 
    member do
      put :request_to_be_champion
      get :validate
      put :assign_champion
      put :toggle_champion
    end
  end
  
  resources :offers, :only => :index do
    member do
      get :accept
      get :reject
    end
  end
  
  match "searches" => "searches#index", :as => "searches"
    
end
