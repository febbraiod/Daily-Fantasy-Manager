class Player < ActiveRecord::Base
  validates :name, presence: true

  #get players to display:

  def self.by_ave_value(players)
    players = players.sort_by {|p|
      if p.projected_points.length == 0
        0
      else
        p.player_value
      end
    }
    players.reject {|p| p.projected_points.length == 0 || average_points(p.projected_points) < 5}
  end

  def self.by_ave_points(players)
    players = players.sort_by {|p|
      if p.projected_points.length == 0
        0
      else
        average_points(p.projected_points)
      end
    }
    players.reject {|p| p.projected_points.length == 0 || average_points(p.projected_points) < 5}.reverse
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

#top_5_finder
  def self.top_5s
    players = Player.all

    qbs = players.select{|p| p.position == 'QB'}
    wrs = players.select{|p| p.position == 'WR'}
    rbs = players.select{|p| p.position == 'RB'}
    tes = players.select{|p| p.position == 'TE'}
    ds = players.select{|p| p.position == 'D'}
    ks = players.select{|p| p.position == 'K'}

    arr = [tops_at_pos(qbs),
           tops_at_pos(wrs),
           tops_at_pos(rbs),
           tops_at_pos(tes),
           tops_at_pos(ds),
           tops_at_pos(ks)]
  end

  def self.top_counts(arr)
    hash = Hash.new(0)

    arr.each do |v|
      hash[v] += 1
    end

    hash.sort_by{|_key, value| value}.reverse
  end

#helpers:

  def player_value
    if self.projected_points.length == 0 || Player.average_points(self.projected_points) < 5
      0
    else
      self.salary/Player.average_points(self.projected_points)
    end
  end

  def self.average_points(arr)
    arr.reduce(0, :+)/arr.length
  end

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

  def self.tops_at_pos(players_at_pos)
    top_ave_proj = Player.by_ave_points(players_at_pos).first(5)
    top_ave_value = Player.by_ave_value(players_at_pos).first(5)
    top_ceilings = top5_ceiling_helper(players_at_pos)
    top_floors =  top5_floor_helper(players_at_pos)
    top_dropoffs =  top5_dropoff_helper(players_at_pos)
    top_cap =  top5_cap_helper(players_at_pos)
    top_dropoffs_5 = top5_dropoff_5_helper(players_at_pos)
    top_cap_5 = top5_cap_5_helper(players_at_pos)

    [top_ave_proj, top_ave_value, top_ceilings, top_floors, top_dropoffs, top_cap, top_dropoffs_5, top_cap_5]
  end

  def self.top5_ceiling_helper(players)
    players.sort_by{|p| p.projected_points.max || 0}.reverse.first(5)
  end

  def self.top5_floor_helper(players)
    players.sort_by{|p| p.projected_points.min || 0}.reverse.first(5)
  end

  def self.top5_dropoff_helper(players)
    players.sort_by{|p| p.dropoff || 0}.reverse.first(5)
  end

  def self.top5_cap_helper(players)
    players.reject!{|n| n.cap.to_s == 'NaN' || n.cap == nil}
    players.sort_by{|p| p.cap.round(2) || 0}.first(5)
  end

  def self.top5_dropoff_5_helper(players)
    players.sort_by{|p| p.dropoff_5 || 0}.reverse.first(5)
  end

  def self.top5_cap_5_helper(players)
    players.sort_by{|p| p.cap_5 || 0}.first(5)
  end

  def self.create_player_dropoffs(players)
    players = players.reject {|p| p.projected_points.length == 0 || average_points(p.projected_points) < 5}
    players.sort_by!{|p| Player.average_points(p.projected_points)}.reverse!
    
    players.each_with_index do |p, i|
      p.dropoff = average_points(p.projected_points) - average_points(players[i+1].projected_points) unless !players[i+1]
      p.cap =  (p.salary - players[i+1].salary)/p.dropoff unless !players[i+1]
      p.dropoff_5 = average_points(p.projected_points) - average_points(players[i+5].projected_points) unless !players[i+5]
      p.cap_5 = (p.salary - players[i+5].salary)/p.dropoff_5 unless !players[i+5]
      p.save
    end
  end

  def self.create_all_players_dropoffs(qbs,wrs,rbs,tes,ks,ds)
    Player.create_player_dropoffs(qbs)
    Player.create_player_dropoffs(wrs)
    Player.create_player_dropoffs(rbs)
    Player.create_player_dropoffs(tes)
    Player.create_player_dropoffs(ks)
    Player.create_player_dropoffs(ds)
  end

end




