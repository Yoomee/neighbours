Neighbours::Application.routes.draw do
  
  root :to => 'home#index'
  resources :wireframes, :only => [:index, :show]
  resources :registrations, :only => [:new, :create]  
  
end
