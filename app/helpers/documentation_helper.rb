module DocumentationHelper
  def link_to_if_logged_in(name = nil, options = nil, html_options = nil, &block)
    if current_user
      link_to(name, options, html_options, &block)
    else
      name
    end
  end
end
