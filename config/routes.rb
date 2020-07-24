Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

scope "(:locale)", locale: /tr|en|ar_EG|es/ do

  get 'new_layout', to: 'translations#new_layout'
  resources :translations,
    only: [:index, :new, :create, :show, :edit, :update] do #, constraints: { :id => /[^\/]+/ }
    collection do
      get 'listing1', to: 'translations#index'
      get 'listing2', to: 'translations#listing2'
    end
  end

  get 'upload_summary', to: 'uploads#upload_summary'
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

  resources :trees,
    only: [:index, :new, :create, :show, :edit, :update] do
    collection do
      get 'index_listing'
      post 'index_listing'
      get 'sequence'
      get 'dimension_form'
      post 'create_dimension'
      patch 'update_dimension'
      get 'dimensions'
      get 'edit_dimensions'
      post 'reorder'
      post 'create_dim_tree'
      patch 'update_dim_tree'
      get 'maint'
      post 'deactivate'
    end
  end
  match '/dim_tree', :to => "trees#dim_tree_add_edit", :as => :dim_tree_path, :via => [:post, :patch, :put]
  resources :tree_trees,
    only: [:index, :new, :create, :show, :edit, :update] do
    collection do
    end
  end

  resources :sectors, only: [:index] do
    collection do
      post 'index'
      get 'index'
    end
  end

  resources :dimensions, only: [:show, :edit, :update] do
    collection do
      post 'show'
      get 'show'
    end
  end

  resources :resources,
    only: [:new, :create, :edit, :update] do
    collection do
    end
  end

  resources :lesson_plans,
    only: [:show, :new, :create] do
    collection do
      post 'make_exemplar'
    end
  end

  resources :activities,
    only: [:new, :create, :edit, :update] do
    collection do
    end
  end

  resources :lookup_tables_options,
    only: [:new, :create] do
    collection do
    end
  end

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }
  devise_scope :user do
    get '/users/sign_out' => 'sessions#destroy'
    get '/sign_out' => 'sessions#destroy'
    get '/signout' => 'sessions#destroy'
    get '/log_out' => 'sessions#destroy'
    get '/logout' => 'sessions#destroy'
  end

  get '/users/lang/:locale', to: 'users#lang', as: :lang_user
  resources :users,
    only: [:index, :new, :create, :show, :edit, :update ] do
    collection do
      get 'registrations'
      get 'index'
      get 'home'
      patch 'set_curriculum'
      patch 'update_home_page'
    end
    member do
      get 'configuration'
    end
  end


  #root to: 'trees#index'
   root to: 'users#home'

end # end routes scope

end # end route.draw
