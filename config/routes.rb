Rails.application.routes.draw do
  # Basic route for root page
  
  get 'schedules/import' => 'schedules#upload_a_csv'
  resources :schedules do
    collection {post :import}
  end

  root :to => redirect('/schedules')


end
