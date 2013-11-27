class Users::RegistrationsController < Devise::RegistrationsController

  def resource_params
    params.require(:user).permit(permitted_attributes)
  end
  def sign_up_params
    params.require(:user).permit(permitted_attributes)
  end
  def account_update_params
    params.require(:user).permit(permitted_attributes.concat(:current_password))
  end

  private
  def permitted_attributes
    return :name, :email, :password, :password_confirmation, :identities_attributes=>[:short_name ]
  end
end
