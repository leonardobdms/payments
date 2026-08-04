class Api::V1::Users::SessionsController < ApplicationController
  before_action :authenticate_user!, only: :destroy

  def create
    return render_unauthorized unless user&.authenticate(user_credential_params[:password])

    tokens = AuthToken::Refresh.issue_for(user)

    render json: { **tokens, user: UserSerializer.render(user) }, status: :ok
  end

  def refresh
    tokens = AuthToken::Refresh.rotate(refresh_token_param)

    return render_unauthorized if tokens.blank?

    render json: { **tokens }, status: :ok
  end

  def destroy
    return render_unauthorized unless AuthToken::Refresh.revoke(refresh_token_param, user: current_user)

    head :no_content
  end

  private

  def user_credential_params
    params.require(:user).permit(
      :email, :password
    )
  end

  def refresh_token_param
    params[:refresh_token]
  end

  def user
    @user ||= User.find_by(email: user_credential_params[:email])
  end
end
