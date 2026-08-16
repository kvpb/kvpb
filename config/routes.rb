Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root "application#index"

  resource :session,      only: %i[new create destroy]
  get "/session/end", to: "sessions#destroy", as: "end_session"
  resource :registration, only: %i[new create]

  get    "/read",                             to: "articles#index",  as: "read"
  post   "/read",                             to: "articles#create"
  get    "/read/new",                         to: "articles#new",    as: "new_article"
  get    "/read/:identifier",                 to: "articles#show",   as: "article"
  get    "/read/:identifier/edit",            to: "articles#edit",   as: "edit_article"
  patch  "/read/:identifier",                 to: "articles#update"
  delete "/read/:identifier",                 to: "articles#destroy"

  post   "/read/:article_identifier/comments",             to: "comments#create",  as: "article_comments"
  patch  "/read/:article_identifier/comments/:id/approve", to: "comments#approve", as: "approve_article_comment"
  delete "/read/:article_identifier/comments/:id/reject",  to: "comments#reject",  as: "reject_article_comment"

  get "/see",                 to: "pages#see",                  as: "see"
  get "/listen",              to: "pages#listen",               as: "listen"
  get "/watch",               to: "pages#watch",                as: "watch"
  get "/gettoknowandcontact", to: "pages#gettoknowandcontact",  as: "gettoknowandcontact"
  get "/search",              to: "pages#search",               as: "search"
end
