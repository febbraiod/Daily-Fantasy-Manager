class OpponentsController < ApplicationController
  require 'csv'

  def opp_upload
  end

  def opponents_import
    Opponent.opp_import(params[:file])
    redirect_to top_fives_path
  end

end
