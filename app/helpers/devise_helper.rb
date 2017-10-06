# frozen_string_literal: true
module DeviseHelper
  ##
  # Override the Devise error messages.
  # See: https://github.com/plataformatec/devise/wiki/Override-devise_error_messages!-for-views.
  def devise_error_messages!(*attrs)
    object_error_messages(resource, *attrs) do |messages|
      <<-HTML
      <div id="error_explanation" class="text-danger">
        <ul>#{messages}</ul>
      </div>
      HTML
    end
  end

  ##
  # Append to labels for password fields.
  def minimum_password_length
    content_tag(:em, " (#{@minimum_password_length} characters minimum)") if @minimum_password_length
  end

  ##
  # Create a password label.
  def password_label(password = "Password")
    h(password) + minimum_password_length
  end
end
