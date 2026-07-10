Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Rails 8's authentication generator deliberately ships no sign-up flow
  # (registration is app-specific) — this pair is the one we add.
  get  "sign_up" => "registrations#new"
  post "sign_up" => "registrations#create"

  # Singular, no :id — there is no URL to edit to request someone else's
  # profile. Current.user makes the scoping structural, not a runtime check.
  resource :profile, only: [:show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # All seven standard bookmark URLs (list/show/new/create/edit/update/delete).
  # Risk if removed: every bookmark page 404s.
  resources :bookmarks

  # The bookmarks list is the homepage — visiting "/" shows it directly.
  root "bookmarks#index"
end
