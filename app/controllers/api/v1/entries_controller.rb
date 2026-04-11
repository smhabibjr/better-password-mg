class Api::V1::EntriesController < Api::V1::ApiBaseController
  def index
    @entries = current_user.entries
    render json: @entries
  end
end