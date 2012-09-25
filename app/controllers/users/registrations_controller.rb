class Users::RegistrationsController < Devise::RegistrationsController

  def resource_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :identities_attributes=>[:short_name ])
  end
end
