class Api::V1::Users::RegistrationsController < ApplicationController
  def create
    return render_unprocessable_content(user.errors) unless user.save

    tokens = AuthToken::Refresh.issue_for(user)

    render json: { **tokens, user: UserSerializer.render(user) }, status: :created
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
end
