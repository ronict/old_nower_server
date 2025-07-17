Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Root route
  root "users#index"

  # RESTful resources
  resources :promos, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'locations', to: 'branches#get_by_locations'
      post 'details', to: 'promos#fetch_promos'
      post 'locations', to: 'branches#get_by_locations_in_range'
      post 'locations/ids', to: 'branches#get_by_locations_in_range_ids'
    end
    member do
      get 'store', to: 'promos#get_by_store'
    end
  end

  resources :stores, only: [:index, :show, :create, :update, :destroy] do
    member do
      get 'branches', to: 'stores#get_branches'
    end
    collection do
      post 'login', to: 'stores#login'
    end
  end

  resources :users, only: [:index, :show, :create] do
    member do
      get 'redemptions', to: 'users#get_redemptions'
    end
    collection do
      post 'login', to: 'users#login'
      post 'login/facebook', to: 'users#facebook_login'
    end
  end

  resources :branches, only: [:index, :create, :update, :destroy]
  resources :categories, only: [:index, :show, :create]

  # Custom routes
  post 'redemptions/redeem', to: 'redemptions#redeem'
  post 'promo/now', to: 'redemptions#generate_code'
end
