class Api::V1::Users::SessionsController < ApplicationController
  before_action :authenticate_user!, only: :destroy

  def create
    return render_unauthorized unless user&.authenticate(user_credential_params[:password])

    render_authenticated
  end

  def refresh
    tokens = AuthToken::Refresh.new(token: refresh_token_param).refresh!
    return render_unauthorized if tokens.blank?

    render json: {
      token: tokens[:access_token],
      refresh_token: tokens[:refresh_token]
    }, status: :ok
  end

  def destroy
    revoked = AuthToken::Refresh.new(token: refresh_token_param, user: current_user).revoke!
    return render_unauthorized unless revoked

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

  def render_authenticated
    tokens = AuthToken::Refresh.new(user: user).issue


    render json: {
      token: tokens[:access_token],
      refresh_token: tokens[:refresh_token],
      user: user.as_json
    }, status: :ok
  end
end
