Rails.application.routes.draw do
  
  root 'players#index'
  resources :players

  get '/fdupload' => 'data#fd_upload'
  post '/fdimport' => 'data#fd_import'

  get '/proj_upload' => 'data#proj_upload'

  post '/yahoo_proj_import' => 'data#yahoo_proj_import'
  post '/fantasypros_proj_import' => 'data#fantasypros_proj_import'
  post '/rotoworld_proj_import' => 'data#rotoworld_proj_import'
  post '/fantasyanalytics_proj_import' => 'data#fantasyanalytics_proj_import'

  get 'csv_output' => 'players#csv_output'
  get 'ceil_output' => 'players#ceil_output'
  get 'floor_output' => 'players#floor_output'
  
end
