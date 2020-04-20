Rails.application.routes.draw do
  
  resources :schedules do
    collection {
      post :import
      post :delete
    }
  end
  
  resources :performances do
    collection {
      put :sort
      post :remove
      post :lock
      post :revive
    }
  end

  root :to => redirect('/schedules')

end
