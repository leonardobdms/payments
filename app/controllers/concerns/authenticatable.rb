module Authenticatable
  extend ActiveSupport::Concern

  private

  attr_reader :current_user

  def authenticate_user!
    return render_unauthorized if token_decoded.blank?

    @current_user = User.find_by(id: token_decoded[:user_id])

    render_unauthorized unless @current_user.present?
  end

  def token
    @token ||= request.headers["Authorization"]&.split(" ")&.last
  end

  def token_decoded
    @token_decoded ||= AuthToken::Token.decode(token)
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
