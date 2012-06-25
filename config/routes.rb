Neighbours::Application.routes.draw do
  
  root :to => 'home#index'
  resources :wireframes, :only => [:index, :show]
  resources :registrations, :only => [:new, :create]  
  match "registrations/where_you_live" => "registrations#new", :step => "where_you_live", :as => "where_you_live_registration"
  
  resources :needs do
    resources :offers, :only => [:create]
  end
  
  resources :users, :only => []  do
    resources :needs, :only => :index 
  end
  
end
