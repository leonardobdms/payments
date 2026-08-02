class Api::V1::Users::ProfileController < ApplicationController
  before_action :authenticate_user!

  def show
    render_user
  end

  def update
    return render_user if current_user.update(profile_params)

    render_unprocessable_content(current_user.errors)
  end

  def destroy
    current_user.destroy!

    head :no_content
  end

  private

  def profile_params
    params.require(:user).permit(
      :email, :name, :cpf, :password, :password_confirmation
    )
  end

  def render_user
    render json: current_user.as_json, status: :ok
  end
end
