Rails.application.routes.draw do
  # Basic route for root page
  
  resources :schedules do
    collection {post :import}
  end

  root :to => redirect('/schedules')


end
