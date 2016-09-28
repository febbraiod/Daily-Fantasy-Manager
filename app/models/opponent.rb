class Opponent < ActiveRecord::Base

  has_many :players

  def self.opp_import(file)
    CSV.foreach(file.tempfile, headers: true) do |row|
      opp = Opponent.find_or_create_by(team: row['Team'])
      opp.qb = row['QB']
      opp.wr = row['WR']
      opp.rb = row['RB']
      opp.te = row['TE']
      opp.save
    end
  end


end
