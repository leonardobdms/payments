class ApplicationController < ActionController::API
  private

  def current_user
    @current_user
  end

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

  def render_unprocessable_content(errors = nil)
    render json: { errors: errors.presence || "Unprocessable Content" }, status: :unprocessable_content
  end

  def render_not_found
    render json: { error: "Not Found" }, status: :not_found
  end
end
