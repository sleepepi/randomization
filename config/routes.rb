Randomization::Application.routes.draw do

  resources :projects do
    collection do
      post :add_treatment_arm
      post :add_stratification_factor
      post :add_option
      post :generate_lists
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users do
    member do
      post :update_settings
    end
  end

  get "/settings" => "users#settings", as: :settings

  root 'projects#index'

end
