Rails.application.routes.draw do
  get 'csv_test/index'

  root 'csv_test#index'
end
