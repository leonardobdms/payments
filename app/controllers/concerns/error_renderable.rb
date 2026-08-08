module ErrorRenderable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  end

  private

  def render_unprocessable_content(errors = nil)
    render json: { errors: errors.presence || "Unprocessable Content" }, status: :unprocessable_content
  end

  def render_not_found
    render json: { error: "Not Found" }, status: :not_found
  end
end
