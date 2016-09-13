class PlayersController < ApplicationController
  require 'csv'

  def index
    players = Player.all_by_ave_value.sort_by{|p| p.ownership || p.salary}
    @qbs = players.select {|p| p.position == 'QB'}
      @ave_qb = Player.ave_player_at_pos(@qbs)
      @top_10_qb = Player.ave_player_at_pos(@qbs.sort_by{ |p| p.salary}.last(10))
    @wrs = players.select {|p| p.position == 'WR'}
      @ave_wr = Player.ave_player_at_pos(@wrs)
      @top_10_wr = Player.ave_player_at_pos(@wrs.sort_by{ |p| p.salary}.last(10))
    @rbs = players.select {|p| p.position == 'RB'}
      @ave_rb = Player.ave_player_at_pos(@rbs)
      @top_10_rb = Player.ave_player_at_pos(@rbs.sort_by{ |p| p.salary}.last(10))
    @tes = players.select {|p| p.position == 'TE'}
      @ave_te = Player.ave_player_at_pos(@tes)
      @top_10_te = Player.ave_player_at_pos(@tes.sort_by{ |p| p.salary}.last(10))
    @ds = players.select {|p| p.position == 'D'}
      @ave_d = Player.ave_player_at_pos(@ds)
      @top_10_d = Player.ave_player_at_pos(@ds.sort_by{ |p| p.salary}.last(10))
    @ks = players.select {|p| p.position == 'K'}
      @ave_k = Player.ave_player_at_pos(@ks)
      @top_10_k = Player.ave_player_at_pos(@ks.sort_by{ |p| p.salary}.last(10))
  end

  def react_index
    @players = Player.all_by_ave_value
  end

  def show
  end

  def csv_output
    @output = Player.all_by_ave_value.reverse
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"dons_projections.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def ceil_output
    @output = Player.all_by_ave_value.reverse
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"ceil_projections.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def floor_output
    @output = Player.all_by_ave_value.reverse
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"floor_projections.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

end
