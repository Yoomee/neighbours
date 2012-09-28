Neighbours::Application.routes.draw do

  root :to => 'neighbourhoods#show'

  match 'feedback' => 'enquiries#new', :id => 'feedback'
  match 'other-neighbourhoods' => 'enquiries#new', :id => 'other_neighbourhood', :as => "other_neighbourhood"

  resources :wireframes, :only => [:index, :show]
  resources :registrations, :only => [:new]
  match "registrations(/:step)" => "registrations#create", :via => [:post, :put], :as => 'registrations'
  match "registrations/who_you_are" => "registrations#new", :step => "who_you_are", :as => "who_you_are_registration", :via => :get
  match "registrations/where_you_live" => "registrations#new", :step => "where_you_live", :as => "where_you_live_registration", :via => :get
  match "registrations/validate" => "registrations#new", :step => "validate", :as => "validate_registration"

  resources :needs do
    resources :offers, :only => [:create]
    collection do
      get :search
    end
  end

  match "neighbourhood" => "neighbourhoods#show", :as => "neighbourhood"
  match "neighbourhoods/:neighbourhood/posts" => "posts#index", :as => 'neighbourhood_posts'

  resources :need_categories, :except => [:show] do
    resources :needs, :only => :new
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

  resources :offers, :only => :index do
    member do
      get :accept
      get :reject
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

  match "searches" => "searches#index", :as => "searches"

end
