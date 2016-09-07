class PlayersController < ApplicationController

  def index
    players = Player.all_by_ave_value
    @qbs = players.select {|p| p.position == 'QB'}
      @ave_qb = Player.ave_player_at_pos(@qbs)
    @wrs = players.select {|p| p.position == 'WR'}
      @ave_wr = Player.ave_player_at_pos(@wrs)
    @rbs = players.select {|p| p.position == 'RB'}
      @ave_rb = Player.ave_player_at_pos(@rbs)
    @tes = players.select {|p| p.position == 'TE'}
      @ave_te = Player.ave_player_at_pos(@tes)
    @ds = players.select {|p| p.position == 'D'}
      @ave_d = Player.ave_player_at_pos(@ds)
    @ks = players.select {|p| p.position == 'K'}
      @ave_k = Player.ave_player_at_pos(@ks)
  end

  def show
  end

end
