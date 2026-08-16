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

  get    "/hall-of-fame",                     to: "honorees#index",  as: "hall_of_fame"
  post   "/hall-of-fame",                     to: "honorees#create"
  get    "/hall-of-fame/new",                 to: "honorees#new",    as: "new_honoree"
  get    "/hall-of-fame/:identifier",         to: "honorees#show",   as: "honoree"
  get    "/hall-of-fame/:identifier/edit",    to: "honorees#edit",   as: "edit_honoree"
  patch  "/hall-of-fame/:identifier",         to: "honorees#update"
  delete "/hall-of-fame/:identifier",         to: "honorees#destroy"

  get "/see",                 to: "pages#see",                  as: "see"
  get "/listen",              to: "pages#listen",               as: "listen"
  get "/watch",               to: "pages#watch",                as: "watch"
  get "/gettoknowandcontact", to: "pages#gettoknowandcontact",  as: "gettoknowandcontact"
  get "/search",              to: "pages#search",               as: "search"

  post   "/gettoknowandcontact/contact",             to: "contacts#create",    as: "contact"
  get    "/gettoknowandcontact/milestones/new",      to: "milestones#new",     as: "new_milestone"
  post   "/gettoknowandcontact/milestones",          to: "milestones#create", as: "milestones"
  get    "/gettoknowandcontact/milestones/:id/edit", to: "milestones#edit",    as: "edit_milestone"
  patch  "/gettoknowandcontact/milestones/:id",      to: "milestones#update"
  delete "/gettoknowandcontact/milestones/:id",      to: "milestones#destroy", as: "milestone"

  # The sign-in path is not a fixed word ("session"/"login") but today's rotating token, checked
  # against the database on every request by LoginTokenConstraint — so it is neither a guessable
  # target for credential-stuffing bots nor a static secret baked into the deployed code. Kept last
  # so every more specific route above gets first refusal at matching.
  constraints( LoginTokenConstraint ) do
    get    "/:token/new", to: "sessions#new",     as: "new_session"
    post   "/:token",     to: "sessions#create",  as: "session"
    delete "/:token",     to: "sessions#destroy"
    get    "/:token/end", to: "sessions#destroy", as: "end_session"
  end
end

#	routes.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
