Rails.application.routes.draw do
  
  resources :schedules do
    collection {
      post :import
<<<<<<< HEAD
      post :export
=======
      post :delete
>>>>>>> d86bff0bab63b7ea2798906b31a19558aabcfe26
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
