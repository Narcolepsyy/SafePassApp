class EntriesController < ApplicationController
  # we define new instance in entry model here
  before_action :authenticate_user!
  def new
    @entry = Entry.new
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
    params.expect(entry: [ :name, :url, :username, :password ])
  end
end
