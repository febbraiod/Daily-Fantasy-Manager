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

end
