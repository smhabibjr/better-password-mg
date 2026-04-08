class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: [:show, :destroy, :update, :edit] # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets

  def index
    @entries = current_user.entries.order(:name)
    @main_entry = current_user.entries.order(:name).first
  end

  def new
    @entry = Entry.new
  end

  def show
  end

  def create
    # current_user is come from devise, it gives us the currently logged in user, and we build a new entry associated with that user using the entry_params from the form. If the entry saves successfully, we redirect to the entries index page with a success notice. If it fails to save (e.g., due to validation errors), we render the new entry form again so the user can correct any issues.
    @entry = current_user.entries.new(entry_params)
    if @entry.save
        flash.now[:notice] = "<strong>#{@entry.name}</strong> Entry created successfully.".html_safe
        respond_to do |format|
          format.html { redirect_to root_path }
          format.turbo_stream
        end
    else
      flash.now[:alert] = "Failed to create entry."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @entry.update(entry_params)
      flash.now[:notice] = "<strong>#{@entry.name}</strong> Entry updated successfully.".html_safe
      respond_to do |format|
        format.html { redirect_to root_path }
        format.turbo_stream
      end
    else
      flash.now[:alert] = "Failed to update entry."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    flash.now[:notice] = "<strong>#{@entry.name}</strong> Entry deleted successfully.".html_safe
    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream
    end
  end

  private

  def entry_params
    # params.require(:entry).permit(:name, :url, :username, :password)
    # scince rails 8 strong parameters have been simplified, we can just use params.expect(:name, :url, :username, :password)
    params.expect(entry: [:name, :url, :username, :password])
  end

  def set_entry
    @entry = current_user.entries.find(params[:id])
  end
end