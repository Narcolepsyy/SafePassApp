class EntriesController < ApplicationController
  # we define new instance in entry model here
  before_action :authenticate_user!
  before_action :set_entry, only: [ :show, :destroy ]
  # this will ensure that user is logged in before accessing any action in this controller
  # # if user is not logged in, it will redirect to login page
  def index
    @entries = current_user.entries
    @main_entry = current_user.entries.first
  end
  def new
    @entry = Entry.new
  end
  # this will create a new instance of entry model
  # and render the new view
  def show
    @entry = current_user.entries.find(params[:id])
  end

  def create
    @entry = current_user.entries.new(entry_params)

    if @entry.save
      flash.now[:notice] = "<strong>#{@entry.name}</strong> has been created.".html_safe
      respond_to do |format|
        format.html { redirect_to root_path }
        format.turbo_stream { }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    flash.now[:notice] = "#{@entry.name} has been deleted."
    respond_to do |format|
      format.html { redirect_to root_path, status: :see_other }
      format.turbo_stream { }
    end
  end
  private
  def entry_params
    params.require(:entry).permit(:name, :url, :username, :password)
  end
  def set_entry
    @entry = current_user.entries.find(params[:id])
  end
end
