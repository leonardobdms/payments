class Api::V1::Users::SessionsController < ApplicationController
  before_action :authenticate_user!, only: :destroy

  def create
    return render_unauthorized unless user&.authenticate(user_credential_params[:password])

    render_authenticated
  end

  def destroy
    head :no_content
  end

  private

  def user_credential_params
    params.require(:user).permit(
      :email, :password
    )
  end

  def user
    @user ||= User.find_by(email: user_credential_params[:email])
  end

  def render_authenticated
    render json: {
      token: AuthToken.encode({ user_id: user.id }),
      user: user.as_json
    }, status: :ok
  end
end
