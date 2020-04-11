Rails.application.routes.draw do
  
  resources :schedules do
    collection {
      post :import
    }
  end
  
  resources :performances do
    collection {
      put :sort
      post :lock
    }
  end

  root :to => redirect('/schedules')

end
