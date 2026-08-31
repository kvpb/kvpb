Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")

  resource :registration, only: %i[new create]









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
  get "/search",                    to: "pages#search",               as: "search"





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

  # The site's own page for the error Rails itself raises, at the exact address
  # ActionDispatch::PublicExceptions already sends a request to for that status — config.exceptions_app =
  # routes, in config/application.rb, points here instead of there for every one of the five it ever raises
  # on its own (400/404/406/422/500). Left open to any error status at all, not only those five, is the
  # easter egg itself: kvpb.fr/404, kvpb.fr/503 both reach it directly, nothing behind them having actually
  # gone wrong — but only a real one. kvpb.fr/499 isn't a status HTTP itself ever defines, so it isn't one of
  # these digits either, and a request for it falls through to no route at all, same as any other address
  # nothing here answers to: a genuine 404, not a make-believe 499. public/*.html, Rails' own last resort —
  # if the error is this very page failing to render — no longer shares a single one of these addresses with
  # it, which is what once stood in front of every one of them
  #
  # A real status is whatever HttpStatusRegistry.error_codes currently says one is — read fresh every time,
  # not a fixed list typed out here once and left to go stale, so a code the registry only adds later starts
  # answering to this the very next day, no redeploy asked for. That class is where the fuller story of
  # where this comes from, and how it stays current, is told
  match "/:status", to: "errors#show", via: :all, constraints: ->( request ) { HttpStatusRegistry.error_codes.key?( request.path_info.delete_prefix( "/" ).to_i ) }
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
