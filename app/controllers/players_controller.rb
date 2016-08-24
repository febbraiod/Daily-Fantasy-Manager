class PlayersController < ApplicationController

  def index
    @players = Player.all_by_ave_value
  end

  def show
  end

end
