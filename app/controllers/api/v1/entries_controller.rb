class Api::V1::EntriesController < ApplicationController
  def index
    @entries = current_user.entries
    render json: @entries
  end
end