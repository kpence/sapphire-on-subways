Rails.application.routes.draw do
  
  resources :schedules do
    collection {
      post :import
      post :insert, :to => 'schedules#insert'
    }
  end
  
  resources :performances do
    collection {
      put :sort
      post :insert, :to => 'performances#create'
    }
  end

  root :to => redirect('/schedules')

end
