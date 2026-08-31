Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#gettoknowandcontact"

  resource :registration, only: %i[new create]

  # the old primary — read_path and friends keep their own name below, only the literal URL they
  # generate changes, so nothing that calls read_path/article_path/article_comments_path etc.
  # anywhere else in the app needs to change
  # get    "/journal",                          to: "articles#index"
  # get    "/read",                             to: "articles#index",  as: "read"
  # post   "/read",                             to: "articles#create"
  # get    "/read/new",                         to: "articles#new",    as: "new_article"
  # get    "/read/:identifier",                 to: "articles#show",   as: "article"
  # get    "/read/:identifier/edit",            to: "articles#edit",   as: "edit_article"
  # patch  "/read/:identifier",                 to: "articles#update"
  # delete "/read/:identifier",                 to: "articles#destroy"
  #
  # post   "/read/:article_identifier/comments",             to: "comments#create",  as: "article_comments"
  # patch  "/read/:article_identifier/comments/:id/approve", to: "comments#approve", as: "approve_article_comment"
  # delete "/read/:article_identifier/comments/:id/reject",  to: "comments#reject",  as: "reject_article_comment"
  get    "/read",                             to: "articles#index",  as: "old_read"
  get    "/journal",                          to: "articles#index",  as: "read"
  post   "/journal",                          to: "articles#create"
  get    "/journal/new",                      to: "articles#new",    as: "new_article"
  get    "/journal/:identifier",              to: "articles#show",   as: "article"
  get    "/journal/:identifier/edit",         to: "articles#edit",   as: "edit_article"
  patch  "/journal/:identifier",              to: "articles#update"
  delete "/journal/:identifier",              to: "articles#destroy"

  post   "/journal/:article_identifier/comments",             to: "comments#create",  as: "article_comments"
  patch  "/journal/:article_identifier/comments/:id/approve", to: "comments#approve", as: "approve_article_comment"
  delete "/journal/:article_identifier/comments/:id/reject",  to: "comments#reject",  as: "reject_article_comment"

  # the old primary — hall_of_fame_path and friends keep their own name below, only the literal URL changes
  # get    "/hall-of-fame",                     to: "honorees#index",  as: "hall_of_fame"
  # post   "/hall-of-fame",                     to: "honorees#create"
  # get    "/hall-of-fame/new",                 to: "honorees#new",    as: "new_honoree"
  # get    "/hall-of-fame/:identifier",         to: "honorees#show",   as: "honoree"
  # get    "/hall-of-fame/:identifier/edit",    to: "honorees#edit",   as: "edit_honoree"
  # patch  "/hall-of-fame/:identifier",         to: "honorees#update"
  # delete "/hall-of-fame/:identifier",         to: "honorees#destroy"
  get    "/hall-of-fame",                     to: "honorees#index",  as: "old_hall_of_fame"
  get    "/halloffame",                       to: "honorees#index",  as: "hall_of_fame"
  post   "/halloffame",                       to: "honorees#create"
  get    "/halloffame/new",                   to: "honorees#new",    as: "new_honoree"
  get    "/halloffame/:identifier",           to: "honorees#show",   as: "honoree"
  get    "/halloffame/:identifier/edit",      to: "honorees#edit",   as: "edit_honoree"
  patch  "/halloffame/:identifier",           to: "honorees#update"
  delete "/halloffame/:identifier",           to: "honorees#destroy"

  # the old primary — see_path and friends keep their own name below, only the literal URL changes
  # get    "/gallery",                          to: "albums#index"
  # get    "/see",                              to: "albums#index",    as: "see"
  # post   "/see",                              to: "albums#create"
  # get    "/see/new",                          to: "albums#new",      as: "new_album"
  # get    "/see/stats",                        to: "photo_dwells#index", as: "photo_dwells"
  # get    "/see/stats/events",                 to: "photo_dwell_events#index",   as: "photo_dwell_events"
  # delete "/see/stats/events/:id",             to: "photo_dwell_events#destroy", as: "photo_dwell_event"
  # get    "/see/:identifier",                  to: "albums#show",     as: "album"
  # get    "/see/:identifier/edit",             to: "albums#edit",     as: "edit_album"
  # patch  "/see/:identifier",                  to: "albums#update"
  # delete "/see/:identifier",                  to: "albums#destroy"
  #
  # get    "/see/prints/:identifier",           to: "prints#show",     as: "print"
  #
  # get    "/see/:album_identifier/photos/:id/edit", to: "photos#edit",    as: "edit_photo"
  # patch  "/see/:album_identifier/photos/:id",      to: "photos#update"
  # delete "/see/:album_identifier/photos/:id",      to: "photos#destroy", as: "photo"
  #
  # get    "/see/:album_identifier/passages/new",      to: "passages#new",     as: "new_passage"
  # post   "/see/:album_identifier/passages",          to: "passages#create",  as: "passages"
  # get    "/see/:album_identifier/passages/:id/edit", to: "passages#edit",    as: "edit_passage"
  # patch  "/see/:album_identifier/passages/:id",      to: "passages#update"
  # delete "/see/:album_identifier/passages/:id",      to: "passages#destroy", as: "passage"
  get    "/see",                              to: "albums#index",    as: "old_see"
  get    "/gallery",                          to: "albums#index",    as: "see"
  post   "/gallery",                          to: "albums#create"
  get    "/gallery/new",                      to: "albums#new",      as: "new_album"
  get    "/gallery/stats",                    to: "photo_dwells#index", as: "photo_dwells"
  get    "/gallery/stats/events",             to: "photo_dwell_events#index",   as: "photo_dwell_events"
  delete "/gallery/stats/events/:id",         to: "photo_dwell_events#destroy", as: "photo_dwell_event"
  get    "/gallery/:identifier",              to: "albums#show",     as: "album"
  get    "/gallery/:identifier/edit",         to: "albums#edit",     as: "edit_album"
  patch  "/gallery/:identifier",              to: "albums#update"
  delete "/gallery/:identifier",              to: "albums#destroy"

  get    "/gallery/prints/:identifier",       to: "prints#show",     as: "print"

  get    "/gallery/:album_identifier/photos/:id/edit", to: "photos#edit",    as: "edit_photo"
  patch  "/gallery/:album_identifier/photos/:id",      to: "photos#update"
  delete "/gallery/:album_identifier/photos/:id",      to: "photos#destroy", as: "photo"

  get    "/gallery/:album_identifier/passages/new",      to: "passages#new",     as: "new_passage"
  post   "/gallery/:album_identifier/passages",          to: "passages#create",  as: "passages"
  get    "/gallery/:album_identifier/passages/:id/edit", to: "passages#edit",    as: "edit_passage"
  patch  "/gallery/:album_identifier/passages/:id",      to: "passages#update"
  delete "/gallery/:album_identifier/passages/:id",      to: "passages#destroy", as: "passage"


  # get "/listen",                    to: "pages#listen",               as: "listen"
  get "/listen",                    to: "pages#listen",               as: "old_listen"
  get "/records",                   to: "pages#listen",               as: "listen"
  get "/music",                     to: "pages#listen"
  # get "/watch",                     to: "pages#watch",                as: "watch"
  get "/watch",                     to: "pages#watch",                as: "old_watch"
  get "/videos",                    to: "pages#watch",                as: "watch"
  get "/video",                     to: "pages#watch"
  get "/code",                      to: "pages#code",                 as: "code"
  get "/map",                       to: "pages#map",                  as: "map"
  get "/gettoknowandcontact",       to: "pages#gettoknowandcontact",  as: "gettoknowandcontact"
  # no dedicated URL for this page for now — root above still serves it, and gettoknowandcontact_path
  # above stays live since it's the route helper the nav link, the contact form and the
  # skills/milestones/contacts controllers' redirects all depend on; only the guessable vanity
  # aliases below are out
  # get "/about",                     to: "pages#gettoknowandcontact"
  # get "/Karl",                      to: "pages#gettoknowandcontact"
  # get "/karl",                      to: "pages#gettoknowandcontact"
  # get "/KVPB",                      to: "pages#gettoknowandcontact"
  # get "/kvpb",                      to: "pages#gettoknowandcontact"
  # get "/KTGW",                      to: "pages#gettoknowandcontact"
  # get "/ktgw",                      to: "pages#gettoknowandcontact"
  # get "/KarlVincentPierreBertin",   to: "pages#gettoknowandcontact"
  # get "/KarlThomasGeorgeWest",      to: "pages#gettoknowandcontact"
  get "/search",                    to: "pages#search",               as: "search"

  post   "/gettoknowandcontact/contact",             to: "contacts#create",    as: "contact"
  get    "/gettoknowandcontact/milestones/new",      to: "milestones#new",     as: "new_milestone"
  post   "/gettoknowandcontact/milestones",          to: "milestones#create", as: "milestones"
  get    "/gettoknowandcontact/milestones/:id/edit", to: "milestones#edit",    as: "edit_milestone"
  patch  "/gettoknowandcontact/milestones/:id",      to: "milestones#update"
  delete "/gettoknowandcontact/milestones/:id",      to: "milestones#destroy", as: "milestone"

  get    "/gettoknowandcontact/skills/new",      to: "skills#new",     as: "new_skill"
  post   "/gettoknowandcontact/skills",          to: "skills#create", as: "skills"
  get    "/gettoknowandcontact/skills/:id/edit", to: "skills#edit",    as: "edit_skill"
  patch  "/gettoknowandcontact/skills/:id",      to: "skills#update"
  delete "/gettoknowandcontact/skills/:id",      to: "skills#destroy", as: "skill"



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
