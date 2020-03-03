Rails.application.routes.draw do
  # Basic route for root page
  resources :schedules
  root :to => redirect('/schedules')
end
