class EntriesController < ApplicationController
  # we define new instance in entry model here
  before_action :authenticate_user!
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
      flash[:notice] = "Entry has been created."
      redirect_to root_path
    else
      flash[:alert] = "Sorry, there was an error."
      render :new, status: :unprocessable_entity
    end
  end
  private
  def entry_params
    params.require(:entry).permit(:name, :url, :username, :password)
  end
end
