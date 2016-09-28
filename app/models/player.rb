class Player < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :opponent

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

  def self.top5_details(matrix)
    details_obj = {}
    positions = ['QB','WR','RB','TE','D','K']
    cats = ['Top Ave Projection', 'Top Ave Value', 'Top Ceiling', 'Top floor', 
            'Top Dropoff', 'Top Cost Per Addition Point', 'Top DO to 5th player', 'Top CAP to 5th Player' ]

    i = 0
    j = 0
    matrix.each do |pos_arr|
      details_obj[positions[i]] = {}
        pos_arr.each do |top5_cat|
          cat = cats[j]
          details_obj[positions[i]][cat] = []
          top5_cat.each do |player|
            details_obj[positions[i]][cat] << player.name
          end
          j += 1
        end
      j = 0  
      i += 1
    end
    details_obj
  end

  def self.top_counts(matrix)
    result_obj = {}

    matrix.each do |pos_arr|
      pos_hash = Hash.new(0)
        position = pos_arr[0][0].position
        pos_arr.each do |top5_for_metric|
            top5_for_metric.each do |p|
              pos_hash[p.name] += 1
            end
        end
      result_obj[position] = pos_hash
    end

    result_obj
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




