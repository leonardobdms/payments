class Api::V1::BaseController < ApplicationController
  include Serializable

  before_action :authenticate_user!
end
