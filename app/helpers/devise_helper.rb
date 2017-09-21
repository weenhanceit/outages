##
# Override the Devise error messages.
# See: https://github.com/plataformatec/devise/wiki/Override-devise_error_messages!-for-views.
module DeviseHelper
  def devise_error_messages!
    return "" unless devise_base_error_messages?

    messages = resource.errors.full_messages_for(:base).map do |msg|
      content_tag(:li, msg)
    end.join
    html = <<-HTML
    <div id="error_explanation" class="text-danger">
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def devise_base_error_messages?
    !resource.errors.include?(:base)
  end
end
