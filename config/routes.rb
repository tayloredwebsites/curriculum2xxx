Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'new_layout', to: 'translations#new_layout'
  resources :translations,
    only: [:index, :new, :create, :show, :edit, :update] do #, constraints: { :id => /[^\/]+/ }
    collection do
      get 'listing1', to: 'translations#index'
      get 'listing2', to: 'translations#listing2'
    end
  end

  resources :uploads,
    only: [:index, :new, :create, :show, :edit, :update] do
    collection do
      get 'index2', to: 'translations#index2'
    end
    member do
      get 'start_upload'
      patch 'do_upload'
      post 'do_upload'
      get "do_upload" => "uploads#start_upload"
    end
  end


  devise_for :users

  # root to: 'application#index'
  root to: 'uploads#index'
  get '/elm', to: 'application#index'

end
