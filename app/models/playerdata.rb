class Playerdata < ActiveRecord::Base

  #parsers for imports:

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
      p.slate = setSlate(row[" Kickoff "]) unless p == nil
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
  
  def self.nerds_proj_import
    players = []
    # Must request a specific position: QB, RB, WR, TE, K, DEF. 
    # You can also send along the specific week number (1-17). 
    # If you omit a week, it defaults to the current week.
      players << FFNerd.weekly_rankings('QB')
      players << FFNerd.weekly_rankings('WR')
      players << FFNerd.weekly_rankings('RB')
      players << FFNerd.weekly_rankings('TE')
      players << FFNerd.weekly_rankings('K')
      players.flatten
      binding.pry
    # p = Player.find_by(name: p)
    #   if p == nil
    #     if Player.where("name LIKE ?", "%#{row['playername']}%").length > 1
    #       binding.pry
    #     elsif Player.where("name LIKE ?", "%#{row['playername']}%").length < 1
    #       #ignore player not on fan duel
    #     else
    #       p = Player.where("name LIKE ?", "%#{row['playername']}%")[0] 
    #     end 
    #   end
    # p['projected_points'] << row['points'] unless p == nil
    # p['projected_points'] << row['upper'] unless p == nil
    # p['projected_points'] << row['lower'] unless p == nil
    # p.save unless p == nil
    # end
  end

  def self.ownership_import(file)
    CSV.foreach(file.tempfile, headers: true) do |row|
      p = Player.find_by(name: row['Player'])
        if p == nil
          if Player.where("name LIKE ?", "%#{row['Player']}%").length > 1
            binding.pry
          elsif Player.where("name LIKE ?", "%#{row['Player']}%").length < 1
            #ignore player not on fan duel
          else
            p = Player.where("name LIKE ?", "%#{row['Player']}%")[0] 
          end 
        end
      p['ownership'] = row['Ownership'].chomp('%').to_f unless p == nil
      p.save unless p == nil
    end
  end

end
