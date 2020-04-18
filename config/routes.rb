Rails.application.routes.draw do
  
  resources :schedules do
    collection {
      post :import
      post :delete
    }
    member {
      get :minimize
    }
  end
  
  resources :performances do
    collection {
      put :sort
      post :remove
      post :lock
    }
  end

  root :to => redirect('/schedules')

end
