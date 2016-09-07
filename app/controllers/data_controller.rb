class DataController < ApplicationController
  require 'csv'

  def fd_upload
  end

  def fd_import
    Player.fd_import(params[:file])
    flash[:message] = "File Uploaded"
    redirect_to players_path
  end

  def yahoo_proj_upload
  end

  def yahoo_proj_import
    Player.yahoo_proj_import(params[:file])
    flash[:message] = "File Uploaded"
    redirect_to players_path
  end

  def fantasypros_proj_import
    Player.fantasypros_proj_import(params[:file])
    flash[:message] = "File Uploaded"
    redirect_to players_path
  end

  def rotoworld_proj_import
    Player.rotoworld_proj_import(params[:file])
    flash[:message] = "File Uploaded"
    redirect_to players_path
  end

  def fantasyanalytics_proj_import
    Player.fantasyanalytics_proj_import(params[:file])
    flash[:message] = "File Uploaded"
    redirect_to players_path
  end

end
