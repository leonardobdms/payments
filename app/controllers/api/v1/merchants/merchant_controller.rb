class Api::V1::Merchants::MerchantController < ApplicationController
  before_action :authenticate_user!
  before_action :set_merchant, only: %i[show update]

  def show
    render json: @merchant.as_json, status: :ok
  end

  def create
    if current_user.merchant.present?
      return render json: { error: "Merchant already exists" }, status: :conflict
    end

    merchant = current_user.build_merchant(merchant_params)
    if merchant.save
      render json: merchant.reload.as_json, status: :created
    else
      render_unprocessable_content(merchant.errors)
    end
  end

  def update
    return render json: @merchant.as_json, status: :ok if @merchant.update(merchant_update_params)

    render_unprocessable_content(@merchant.errors)
  end

  private

  def set_merchant
    @merchant = current_user.merchant
    render_not_found unless @merchant
  end

  def merchant_params
    params.require(:merchant).permit(:legal_name, :document)
  end

  def merchant_update_params
    params.require(:merchant).permit(:legal_name)
  end
end
