Rails.application.routes.draw do
  root "projects#index"
  resources :media_imports, only: %i[create show]
  resources :projects, only: %i[index new create show update] do
    member do
      get :media
      get :subtitles
    end
    resources :exports, only: :create do
      get :download, on: :member
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
