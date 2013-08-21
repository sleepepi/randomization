Randomization::Application.routes.draw do
  resources :projects

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users do
    member do
      post :update_settings
    end
  end

  get "/settings" => "users#settings", as: :settings

  root 'projects#index'

end
