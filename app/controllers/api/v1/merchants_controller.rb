class Api::V1::MerchantsController < Api::V1::BaseController
  def index
    render_serialized(merchants)
  end

  def show
    render_serialized(merchant)
  end

  def create
    @merchant = merchants.build(merchant_params)

    return render_serialized(merchant, status: :created) if merchant.save

    render_unprocessable_content(merchant.errors)
  end

  def update
    return render_serialized(merchant) if merchant.update(merchant_update_params)

    render_unprocessable_content(merchant.errors)
  end

  private

  def merchants
    @merchants ||= current_user.merchants
  end

  def merchant
    @merchant ||= merchants.find(params[:id])
  end

  def merchant_params
    params.require(:merchant).permit(:legal_name, :document)
  end

  def merchant_update_params
    params.require(:merchant).permit(:legal_name)
  end
end
