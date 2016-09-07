class PlayersController < ApplicationController

  def index
    players = Player.all_by_ave_value
    @qbs = players.select {|p| p.position == 'QB'}
    @ave_qb = Player.ave_qb(@qbs)
    @wrs = players.select {|p| p.position == 'WR'}
    @rbs = players.select {|p| p.position == 'RB'}
    @tes = players.select {|p| p.position == 'TE'}
    @ds = players.select {|p| p.position == 'D'}
    @ks = players.select {|p| p.position == 'K'}
  end

  def show
  end

end
