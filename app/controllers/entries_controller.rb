class EntriesController < ApplicationController
  # we define new instance in entry model here
  before_action :authenticate_user!
  def new
    @entry = Entry.new
  end
  def create
    @entry = current_user.entries.new
  end
end