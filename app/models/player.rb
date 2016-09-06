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
    if self.projected_points.reduce(0, :+) == 0
      0
    else
      self.salary/self.projected_points.reduce(0, :+)
    end
  end

  def self.fd_import(file)
    CSV.foreach(file.tempfile, headers: true, :header_converters => lambda { |h| h.try(:downcase).tr(" ", "_") }) do |row|
      player_hash = create_player_hash(row)
      create_player_from_hash(player_hash)
    end
  end

  def self.create_player_hash(row)
    player_hash = row.to_hash
    header_map = {"fppg" => "averageppg", "injury_indicator" => "injury_status"}
    player_hash.keys.each { |k| player_hash[ header_map[k] ] = player_hash.delete(k) if header_map[k] }
    player_hash["name"] =  "#{player_hash['first_name']} #{player_hash['last_name']}"
    p = player_hash.except("first_name", "last_name", "played", "", "game", "id", "injury_details")
  end

  def self.create_player_from_hash(player_hash)
    p = Player.find_or_create_by(name: player_hash['name'])
    p.update(player_hash)
    p.save
  end

  # def self.yahoo_proj_import(file)
  #   CSV.foreach(file.tempfile, headers: true) do |row|
  #     binding.pry
  #     # p = Player.find_by(name: row['playername'])
  #     p = Player.where("name LIKE ?", "%#{row['playername']}%")  
  #     p['projected_points'] << row['points']
  #     p.save
  #   end
  # end

end




