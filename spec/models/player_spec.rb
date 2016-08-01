# player_spec.rb

require 'rails_helper'

RSpec.describe Player, type: :model do
  it { should respond_to :name }
  it { should respond_to :salary }
end


describe Player do
  it "should be invalid without name" do
    p = Player.new(salary: 1)
    expect {p.save!}.to raise_error(ActiveRecord::RecordInvalid)
  end

end
