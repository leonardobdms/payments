class ApplicationController < ActionController::API
  include Authenticatable
  include ErrorRenderable
end
