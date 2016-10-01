Rails.application.routes.draw do
  
  root 'players#index'
  resources :players

  get '/topfives' => 'players#topfives'

  get '/fdupload' => 'playerdata#fd_upload'
  post '/fdimport' => 'playerdata#fd_import'

  get '/proj_upload' => 'playerdata#proj_upload'

  post '/yahoo_proj_import' => 'playerdata#yahoo_proj_import'
  post '/fantasypros_proj_import' => 'playerdata#fantasypros_proj_import'
  post '/rotoworld_proj_import' => 'playerdata#rotoworld_proj_import'
  post '/fantasyanalytics_proj_import' => 'playerdata#fantasyanalytics_proj_import'
  get '/nerds_proj_import' => 'playerdata#nerds_proj_import'

  post '/ownership_import' => 'playerdata#ownership_import'

  get 'csv_output' => 'playerdata#csv_output'
  get 'ceil_output' => 'playerdata#ceil_output'
  get 'floor_output' => 'playerdata#floor_output'

  get 'lineup_builder' => 'playerdata#lineup_builder'
  post 'roto_convert_floor' => 'playerdata#roto_convert_floor'
  post 'roto_convert_ceil' => 'playerdata#roto_convert_ceil'
  post 'roto_convert_ave' => 'playerdata#roto_convert_ave'

  get 'opp_upload' => 'opponents#opp_upload'
  post 'opponents_import' => 'opponents#opponents_import'

  delete 'slate_one_kill' => 'playerdata#slate_one_kill'
  delete 'monday_night_kill' => 'playerdata#monday_night_kill'

end
