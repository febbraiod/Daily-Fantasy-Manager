class Player < ActiveRecord::Base
  validates :name, presence: true

  #get players to display
  def self.all_by_ave_value
    players = self.all
    players = players.sort_by {|p|
      p.player_value
    }
    players.reject {|p| p.projected_points.length == 0 || average_points(p.projected_points) < 5}
  end

  def player_value
    if self.projected_points.length == 0 || Player.average_points(self.projected_points) < 5
      0
    else
      self.salary/Player.average_points(self.projected_points)
    end
  end

  #benchmarks:

  def self.ave_player_at_pos(players)
    ave_player = {}
    total_points = 0
    total_sal = 0
    total_cpp = 0
    total_ceil = 0
    total_floor = 0

    players.each do |p|
      total_points += average_points(p.projected_points)
      total_sal += p.salary
      total_cpp += p.player_value
      total_ceil += p.projected_points.max
      total_floor += p.projected_points.min
    end

    ave_player[:points] = total_points/players.length
    ave_player[:salary] = total_sal/players.length
    ave_player[:value] = total_cpp/players.length
    ave_player[:ceiling] = total_ceil/players.length
    ave_player[:floor] = total_floor/players.length

    ave_player
  end

  #import methods:
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

  def self.yahoo_proj_import(file)
    CSV.foreach(file.tempfile, headers: true) do |row|
      p = Player.find_by(name: row['playername'])
        if p == nil
          if Player.where("name LIKE ?", "%#{row['playername']}%").length > 1
            binding.pry
          elsif Player.where("name LIKE ?", "%#{row['playername']}%").length < 1
            #ignore player not on fan duel
          else
            p = Player.where("name LIKE ?", "%#{row['playername']}%")[0] 
          end 
        end
      p['projected_points'] << row['points'] unless p == nil
      p.save unless p == nil
    end
  end

  def self.fantasypros_proj_import(file)
    CSV.foreach(file.tempfile, headers: true) do |row|
      player_name = row["Player "].split(' (')[0]
      p = Player.find_by(name: player_name)
        if p == nil
          if Player.where("name LIKE ?", "%#{player_name}%").length > 1
            binding.pry
          elsif Player.where("name LIKE ?", "%#{player_name}%").length < 1
            #ignore player not on fan duel
          else
            p = Player.where("name LIKE ?", "%#{player_name}%")[0] 
          end 
        end
      p.projected_points << row[" Projected Points "].to_i unless p == nil
      p.save unless p == nil
    end
  end

  def self.rotoworld_proj_import(file)
    CSV.foreach(file.tempfile, headers: true) do |row|
      p = Player.find_by(name: row['player'])
      if p == nil
        if Player.where("name LIKE ?", "%#{row['player']}%").length > 1
          binding.pry
        elsif Player.where("name LIKE ?", "%#{row['player']}%").length < 1
          #ignore player not on fan duel
        else
          p = Player.where("name LIKE ?", "%#{row['player']}%")[0] 
        end 
      end
      p['projected_points'] << row['fpts'] unless p == nil
      p.save unless p == nil
    end
  end

    def self.fantasyanalytics_proj_import(file)
    CSV.foreach(file.tempfile, headers: true) do |row|
      p = Player.find_by(name: row['playername'])
        if p == nil
          if Player.where("name LIKE ?", "%#{row['playername']}%").length > 1
            binding.pry
          elsif Player.where("name LIKE ?", "%#{row['playername']}%").length < 1
            #ignore player not on fan duel
          else
            p = Player.where("name LIKE ?", "%#{row['playername']}%")[0] 
          end 
        end
      p['projected_points'] << row['points'] unless p == nil
      p['projected_points'] << row['upper'] unless p == nil
      p['projected_points'] << row['lower'] unless p == nil
      p.save unless p == nil
    end
  end

#helpers:

  def self.average_points(arr)
    arr.reduce(0, :+)/arr.length
  end


end




