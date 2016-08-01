# player_spec.rb

require 'rails_helper'

RSpec.describe Player, type: :model do
  it { should respond_to :name }
  it { should respond_to :salary }
end
