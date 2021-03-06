class Playerdata < ActiveRecord::Base

  #parsers for imports:

  def self.fd_import(file)
    CSV.foreach(file.tempfile, headers: true, :header_converters => lambda { |h| h.try(:downcase).tr(" ", "_") }) do |row|
      player_hash = create_player_hash(row)
      create_player_from_hash(player_hash, row['opponent'])
    end
  end

  def self.create_player_hash(row)
    player_hash = row.to_hash
    header_map = {"fppg" => "averageppg", "injury_indicator" => "injury_status"}
    player_hash.keys.each { |k| player_hash[ header_map[k] ] = player_hash.delete(k) if header_map[k] }
    player_hash["name"] =  "#{player_hash['first_name']} #{player_hash['last_name']}"
    p = player_hash.except("first_name", "last_name", "played", "", "game", "id", "injury_details", "opponent")
  end

  def self.create_player_from_hash(player_hash, opponent)
    p = Player.find_or_create_by(name: player_hash['name'])
    p.update(player_hash)
    p.opponent = Opponent.find_by(team: opponent)
    p.save
    p
  end

  def self.yahoo_proj_import(file)
    CSV.foreach(file.tempfile, headers: true) do |row|
      row['playername'] == 'LeVeon Bell' ? p = Player.find_by(name: "Le'Veon Bell") : p = Player.find_by(name: row['playername'])
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
      row['playername'] == 'LeVeon Bell' ? p = Player.find_by(name: "Le'Veon Bell") : p = Player.find_by(name: row['playername'])
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
    players.flatten!

    players.each do |player|
      p = Player.find_by(name: player.name)
        if p == nil
          if Player.where("name LIKE ?", "%#{player.name}%").length > 1
            binding.pry
          elsif Player.where("name LIKE ?", "%#{player.name}%").length < 1
            #ignore player not on fan duel
          else
            p = Player.where("name LIKE ?", "%#{player.name}%")[0] 
          end
        end
      p['projected_points'] << (player.standard.to_i + player.ppr.to_i) / 2 unless p == nil
      p['projected_points'] << (player.standard_low.to_i + player.ppr_low.to_i) / 2 unless p == nil
      p['projected_points'] << (player.standard_high.to_i + player.ppr_high.to_i) / 2 unless p == nil
      p.save unless p == nil
    end
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

  #delete method based on slate

  def kill_slate(slate)
    Player.destroy_all("slate <= #{slate}")
  end

  #converts for roto:

  def self.roto_convert_floor(file)
    player_floors = []

    CSV.foreach(file.tempfile, headers: true) do |row|
      current_player = []

      p = Player.find_by(name: row['name'])
        if p == nil
          if Player.where("name LIKE ?", "%#{row['name']}%").length > 1
            binding.pry
          elsif Player.where("name LIKE ?", "%#{row['name']}%").length < 1
            #ignore player not on fan duel
          else
            p = Player.where("name LIKE ?", "%#{row['name']}%")[0] 
          end 
        end
      current_player.push(row['player_id'])
      current_player.push(row['name'])

      if p
        current_player.push(p.projected_points.min)
      else
        current_player.push(0)
      end

      player_floors << current_player
    end

    player_floors
  end

  def self.roto_convert_ceil(file)
    player_ceils = []

    CSV.foreach(file.tempfile, headers: true) do |row|
      current_player = []

      p = Player.find_by(name: row['name'])
        if p == nil
          if Player.where("name LIKE ?", "%#{row['name']}%").length > 1
            binding.pry
          elsif Player.where("name LIKE ?", "%#{row['name']}%").length < 1
            #ignore player not on fan duel
          else
            p = Player.where("name LIKE ?", "%#{row['name']}%")[0] 
          end 
        end
      current_player.push(row['player_id'])
      current_player.push(row['name'])

      if p
        current_player.push(p.projected_points.max)
      else
        current_player.push(row['fpts'])
      end

      player_ceils << current_player
    end

    player_ceils
  end

  def self.roto_convert_ave(file)
    player_aves = []

    CSV.foreach(file.tempfile, headers: true) do |row|
      current_player = []

      p = Player.find_by(name: row['name'])
        if p == nil
          if Player.where("name LIKE ?", "%#{row['name']}%").length > 1
            binding.pry
          elsif Player.where("name LIKE ?", "%#{row['name']}%").length < 1
            #ignore player not on fan duel
          else
            p = Player.where("name LIKE ?", "%#{row['name']}%")[0] 
          end 
        end
      current_player.push(row['player_id'])
      current_player.push(row['name'])

      if p
        current_player.push(Player.average_points(p.projected_points))
      else
        current_player.push(row['fpts'])
      end

      player_aves << current_player
    end

    player_aves
  end

  #export converts:

  def self.to_csv(data)
    CSV.generate do |csv|
      csv << ['player_id', 'name', 'fpts']
        data.each do |player|
          csv << player
        end
    end
  end

  #import helper

  def self.setSlate(time)
    if time[0,3].downcase == 'mon'
      5
    elsif time[0,5].downcase == 'sun 8'
      4
    elsif time[0,5].downcase == 'sun 4'
      3
    elsif time[0,5].downcase == 'sun 1'
      2
    else
      1
    end
  end

end
