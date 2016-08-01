# player_spec.rb

require 'rails_helper'

RSpec.describe Player, type: :model do
  it { should respond_to :name }
  it { should respond_to :salary }
  it { should respond_to :projected_points}
end


describe Player do
  it "should be invalid without name" do
    p = Player.new(salary: 1)
    expect {p.save!}.to raise_error(ActiveRecord::RecordInvalid)
  end
  it "should have an array of projected points" do
    p = Player.new(name: 'Donnie', salary: 1)
    p.save
    expect(p.projected_points).to be_a Array
  end

end
