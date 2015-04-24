Rails.application.routes.draw do

  resources :projects do
    member do
      post :generate_lists
      get :randomize_subject
      post :create_randomization
      get :randomizations
    end

    collection do
      post :add_treatment_arm
      post :add_stratification_factor
      post :add_option
    end

    resources :assignments
  end

  resources :project_users do
    member do
      post :resend
    end
    collection do
      get :accept
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }, path: ""

  resources :users do
    member do
      post :update_settings
    end
  end

  get "/about" => "application#about", as: :about
  get "/settings" => "users#settings", as: :settings

  root 'projects#index'

end
