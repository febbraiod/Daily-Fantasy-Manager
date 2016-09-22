class DataController < ApplicationController
  require 'csv'

  def fd_upload
  end

  def fd_import
    Player.fd_import(params[:file])
    redirect_to players_path
  end

  def proj_upload
  end

  def yahoo_proj_import
    Player.yahoo_proj_import(params[:file])
    redirect_to players_path
  end

  def fantasypros_proj_import
    Player.fantasypros_proj_import(params[:file])
    redirect_to players_path
  end

  def rotoworld_proj_import
    Player.rotoworld_proj_import(params[:file])
    redirect_to players_path
  end

  def fantasyanalytics_proj_import
    Player.fantasyanalytics_proj_import(params[:file])
    redirect_to players_path
  end

  def ownership_import
    Player.ownership_import(params[:file])
    redirect_to players_path
  end

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
