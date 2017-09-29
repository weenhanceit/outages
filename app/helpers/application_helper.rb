# frozen_string_literal: true
module ApplicationHelper
  def home_link
    link_to current_account&.name || "Outage Master",
      root_path,
      class: "navbar-brand"
  end

  def notes_sort_order
    params.fetch(:sort_order, session.fetch(:sort_order, "desc"))
  end

  ##
  # Format object error messages that don't get attached to a specific
  # attribute. This always includes `:base`, but the caller can specify
  # other attributes.
  # The `bootstrap_form` gem has some helpers, but they don't quite do what
  # we need.
  def object_error_messages(resource, *attrs)
    attrs = [attrs] unless attrs.is_a? Array
    attrs |= [:base]

    return "" unless object_error_messages?(resource, *attrs)

    messages = resource.errors.to_hash(true).slice(*attrs).each_value.map do |msg_array|
      msg_array.map do |msg|
        content_tag(:li, msg)
      end
    end.join

    html = if block_given?
             yield messages
           else
             <<-HTML
             <div class="text-danger rails-bootstrap-forms-error-summary">
               <ul>#{messages}</ul>
             </div>
             HTML
           end

    html.html_safe
  end

  def object_error_messages?(resource, *attrs)
    (resource.errors.keys & attrs).present?
  end
end
