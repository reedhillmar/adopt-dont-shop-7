class Admin::SheltersController < ApplicationController
  def index
    @shelters = Shelter.order_by_reverse_alphabetical
    @pending_apps = Shelter.pending_apps.alphabetical_order
  end
end