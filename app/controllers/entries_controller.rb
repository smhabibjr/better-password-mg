class EntriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @entries = current_user.entries
  end

  def new
    @entry = Entry.new
  end

  def create
    #current_user is come from devise, it gives us the currently logged in user, and we build a new entry associated with that user using the entry_params from the form. If the entry saves successfully, we redirect to the entries index page with a success notice. If it fails to save (e.g., due to validation errors), we render the new entry form again so the user can correct any issues.
    @entry = current_user.entries.new(entry_params)
    if @entry.save
        flash[:notice] = "Entry created successfully."
        redirect_to root_path
    else
      flash[:alert] = "Failed to create entry."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def entry_params
    # params.require(:entry).permit(:name, :url, :username, :password)
    
    # scince rails 8 strong parameters have been simplified, we can just use params.expect(:name, :url, :username, :password)
    params.expect(entry: [:name, :url, :username, :password])
  end
end