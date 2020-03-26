Rails.application.routes.draw do
  
  resources :schedules do
    collection {
      post :import
    }
  end
  
  resources :performances do
    collection {
      put :sort
      put :remove
    }
  end

  root :to => redirect('/schedules')

end
