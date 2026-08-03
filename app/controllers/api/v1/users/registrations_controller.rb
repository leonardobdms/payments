class Api::V1::Users::RegistrationsController < ApplicationController
  def create
    return render_created if user.save

    render_unprocessable_content(user.errors)
  end

  private

  def registration_params
    params.require(:user).permit(
      :email, :name, :cpf, :password, :password_confirmation
    )
  end

  def user
    @user ||= User.new(registration_params)
  end

  def render_created
    render json: {
      token: tokens[:access_token],
      refresh_token: tokens[:refresh_token],
      user: user.as_json
    }, status: :created
  end

  def tokens
    @tokens ||= AuthToken::Refresh.new(user:).issue
  end
end
