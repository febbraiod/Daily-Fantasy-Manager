class PlayerdataController < ApplicationController
  require 'csv'

  def fd_upload
  end

  def fd_import
    Playerdata.fd_import(params[:file])
    redirect_to players_path
  end

  def proj_upload
  end

  def yahoo_proj_import
    Playerdata.yahoo_proj_import(params[:file])
    redirect_to players_path
  end

  def fantasypros_proj_import
    Playerdata.fantasypros_proj_import(params[:file])
    redirect_to players_path
  end

  def rotoworld_proj_import
    Playerdata.rotoworld_proj_import(params[:file])
    redirect_to players_path
  end

  def fantasyanalytics_proj_import
    Playerdata.fantasyanalytics_proj_import(params[:file])
    redirect_to players_path
  end

  def nerds_proj_import
    Playerdata.nerds_proj_import
    redirect_to players_path
  end

  def ownership_import
    Playerdata.ownership_import(params[:file])
    redirect_to players_path
  end

  def lineup_builder
  end

  def roto_convert_floor
    @floors = Playerdata.roto_convert_floor(params[:file])
    respond_to do |format|
      format.html
      format.csv { send_data Playerdata.to_csv(@floors) }
    end
  end

  #output
  def csv_output
    @output = Player.by_ave_points(Player.all)
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"dons_projections.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def ceil_output
    @output = Player.by_ave_points(Player.all)
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"ceil_projections.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def floor_output
    @output = Player.by_ave_points(Player.all)
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"floor_projections.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end
end
