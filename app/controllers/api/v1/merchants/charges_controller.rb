class Api::V1::Merchants::ChargesController < Api::V1::BaseController
  def index
    render_serialized(charges)
  end

  def create
    charge = Charges::Create.call(merchant:, params: charge_params)
    render_serialized(charge, status: :created)
  rescue Charges::Create::MerchantInactiveError => e
    render json: { error: e.message }, status: :unprocessable_content
  rescue ActiveRecord::RecordInvalid => e
    render_unprocessable_content(e.record.errors)
  end

  private

  def merchant
    @merchant ||= current_user.merchants.find(params[:merchant_id])
  end

  def charges
    @charges ||= merchant.charges.newest_first
  end

  def charge_params
    params.require(:charge).permit(
      :amount_cents,
      :currency,
      :payment_method,
      :description,
      :customer_email,
      :customer_document,
      metadata: {}
    )
  end
end
