class Api::V1::ChargesController < Api::V1::BaseController
  def show
    render_serialized(charge)
  end

  def cancel
    charge.cancel!
    render_serialized(charge.reload)
  rescue Charge::InvalidTransition => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  def confirm
    confirmed = Charges::Confirm.call(charge: charge)
    render_serialized(confirmed)
  rescue Charges::Confirm::NotConfirmableError => e
    render json: { error: e.message }, status: :unprocessable_content
  rescue Charge::InvalidTransition => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  private

  def charge
    @charge ||= Charge.joins(:merchant)
      .where(merchants: { user_id: current_user.id })
      .find_by!(public_id: params[:public_id])
  end
end
