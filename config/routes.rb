Rails.application.routes.draw do
  
  root 'players#index'
  resources :players

  get '/topfives' => 'players#topfives'

  get '/fdupload' => 'data#fd_upload'
  post '/fdimport' => 'data#fd_import'

  get '/proj_upload' => 'data#proj_upload'

  post '/yahoo_proj_import' => 'data#yahoo_proj_import'
  post '/fantasypros_proj_import' => 'data#fantasypros_proj_import'
  post '/rotoworld_proj_import' => 'data#rotoworld_proj_import'
  post '/fantasyanalytics_proj_import' => 'data#fantasyanalytics_proj_import'

  post '/ownership_import' => 'data#ownership_import'

  get 'csv_output' => 'data#csv_output'
  get 'ceil_output' => 'data#ceil_output'
  get 'floor_output' => 'data#floor_output'

  
end
