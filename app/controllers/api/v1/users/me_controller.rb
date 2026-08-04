class Api::V1::Users::MeController < Api::V1::BaseController
  def show
    render_serialized(current_user)
  end

  def update
    return render_serialized(current_user) if current_user.update(profile_params)

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
end
