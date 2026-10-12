Rails.application.routes.draw do
  # 公開側（1ページ構成）
  root "home#show"
  resources :songs, only: %i[ index show ]
  resources :news, only: %i[ index show ]
  resources :contacts, only: :create

  # 認証
  resource :session
  resources :passwords, param: :token

  # 管理画面
  namespace :admin do
    root "dashboard#show"
    resource :site_setting, only: %i[ show edit update ]
    resource :profile, only: %i[ show edit update ]
    resource :password, only: %i[ edit update ]
    resources :users, only: %i[ index new create destroy ]
    resources :songs, except: :show
    resources :news, except: :show
    resources :contacts, only: %i[ index show update destroy ]
  end

  # SEO
  get "robots.txt" => "seo#robots", as: :robots, format: false
  get "sitemap.xml" => "seo#sitemap", as: :sitemap, defaults: { format: :xml }

  get "up" => "rails/health#show", as: :rails_health_check
end
