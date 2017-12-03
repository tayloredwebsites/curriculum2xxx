Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'new_layout', to: 'translations#new_layout'
  resources :locales do
    resources :translations,
      only: [:index, :new, :create, :show, :edit, :update] #,
      # constraints: { :id => /[^\/]+/ }
  end

  devise_for :users

  root to: 'application#index'

end
