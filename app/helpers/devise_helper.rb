##
# Override the Devise error messages.
# See: https://github.com/plataformatec/devise/wiki/Override-devise_error_messages!-for-views.
module DeviseHelper
  def devise_error_messages!(*attrs)
    object_error_messages(resource, *attrs) do |messages|
      <<-HTML
      <div id="error_explanation" class="text-danger">
        <ul>#{messages}</ul>
      </div>
      HTML
    end
  end
end
