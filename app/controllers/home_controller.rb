class HomeController < ApplicationController
  allow_unauthenticated_access only: [ :show ]
  def show
  end
end
