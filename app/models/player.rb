class Player < ActiveRecord::Base
  validates :name, presence: true


  def self.all_by_ave_value
    players = self.all
    players = players.sort_by {|p|
      p.player_value
    }.reverse
    players
  end

  def player_value
    self.salary/self.projected_points.reduce(0, :+)
  end

  def self.fd_import(file)
    CSV.foreach(file.tempfile, headers: true, :header_converters => lambda { |h| h.try(:downcase).tr(" ", "_") }) do |row|
      player_hash = row.to_hash
      header_map = {"fppg" => "averageppg", "injury_indicator" => "injury_status"}
      player_hash.keys.each { |k| player_hash[ header_map[k] ] = player_hash.delete(k) if header_map[k] }
      player_hash["name"] =  "#{player_hash['first_name']} #{player_hash['last_name']}"
      player_hash = player_hash.except("first_name", "last_name", "played", "", "game", "id", "injury_details")
      binding.pry
      p = Player.find_or_create_by(name: player_hash[:name])
      p.update(player_hash)
      binding.pry
      # p.save
    end
  end

end

 # "position"=>"WR",
 # "first_name"=>"Antonio",
 # "last_name"=>"Brown",
 # "fppg"=>"20.012500762939453",
 # "played"=>"16",
 # "salary"=>"9300",
 # "game"=>"PIT@WAS",
 # "team"=>"PIT",
 # "opponent"=>"WAS",
 # "injury_indicator"=>"",
 # "injury_details"=>"",