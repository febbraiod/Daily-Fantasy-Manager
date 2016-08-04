class Player < ActiveRecord::Base
  validates :name, presence: true


  def self.all_by_ave_value
    players = self.all
    players = players.sort_by {|p|
      p.player_value
    }.reverse
    binding.pry
    players
  end

  def player_value
    self.salary/self.projected_points.reduce(0, :+)
  end

end
