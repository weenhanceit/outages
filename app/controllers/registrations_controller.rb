##
# Subclass the Devise registrations controller to be able to redirect
# to the edit profile path after changing the password.
# See: https://github.com/plataformatec/devise/wiki/How-To:-Customize-the-redirect-after-a-user-edits-their-profile
class RegistrationsController < Devise::RegistrationsController
  protected

    def after_update_path_for(_resource)
      edit_user_path
    end
end
