##
# Subclass the Rails Bootstrap class to augment it with We Enhance IT-specific
# items.
# We need the Rails Boostrap Form gem:
# https://github.com/bootstrap-ruby/rails-bootstrap-forms
class WeitFormBuilder < BootstrapForm::FormBuilder
  # Find formatters.rb in app/lib
  # include Formatters
  # def bootstrap_form_for(object, options = {}, &block)
  #   super(object, options, &block)
  # end

  # Returns a check_box tag
  # rubocop:disable Metrics/ParameterLists
  def check_box(method,
    options = {},
    checked_value = "1",
    unchecked_value = "0")
    process_width(options) { super }
  end

  # provides a set of radio buttons from a provided collection
  def collection_radio_buttons(method,
    collection,
    value_method,
    text_method,
    options = {}, &block)
    process_width(options) { super }
  end
  # rubocop: Metrics/ParameterLists

  ##
  # Provide a drop-down select from a provided collection
  # If column_width: n or :col_width: n is given as an option, wrap in a
  # Bootstrap grid column.
  def collection_select(method,
    collection,
    value_method,
    text_method,
    options = {},
    html_options = {})
    process_options(method, options)
    process_width(options) { super }
  end

  ##
  # Format a currency field.
  def currency_field(method, options = {})
    options = process_options(method, options)
    options[:value] ||= @template.number_to_currency(object.send(method),
      unit: "")
    process_width(options) { text_field(method, options) }
  end

  ##
  # Format a date field.
  # If column_width: n or :col_width: n is given as an option, wrap in a
  # Bootstrap grid column.
  def date_field(method, options = {})
    process_width(options) { super }
  end

  ##
  # Format a datetime field.
  # If column_width: n or :col_width: n is given as an option, wrap in a
  # Bootstrap grid column.
  def datetime_field(method, options = {})
    process_width(options) { super }
  end

  alias datetime_local_field datetime_field

  ##
  # Format a form group.
  # If column_width: n or :col_width: n is given as an option, wrap in a
  # Bootstrap grid column.
  # I'm just guessing about the arguments to this one, since it's not a Rails
  # helper, but rather a Bootstrap Forms helper.
  # pmc: 20161110 - added default empty hash for options
  def form_group(method, options = {}, &block)
    process_width(options) { super }
  end

  ##
  # Format a number field.
  # If column_width: n or :col_width: n is given as an option, wrap in a
  # Bootstrap grid column.
  def number_field(method, options = {})
    options = process_options(method, options)
    process_width(options) { super }
  end

  ##
  # Format a phone number field and show it with punctuation
  def phone_field(method, options = {})
    options = process_options(method, options)
    options[:value] ||= @template.number_to_phone(object.send(method),
      area_code: true)
    process_width(options) { super }
  end

  ##
  # Format a Canadian postal code field, or leave it untouched it if doesn't
  # look like a Canadian postal code
  def postal_code_field(method, options = {})
    options = process_options(method, options)
    options[:value] ||= format_postal_code(object.send(method))
    text_field(method, options)
  end

  ##
  # Output radio buttons that can't be changed, effectively giving a disabled
  # radio button group.
  # http://stackoverflow.com/questions/1953017/why-cant-radio-buttons-be-readonly
  def radio_button_static(method, tag_value, options = {})
    options[:disabled] = true unless object.send(method).to_s == tag_value
    radio_button(method, tag_value, options)
  end

  ##
  # Format a select field.
  # If column_width: n or :col_width: n is given as an option, wrap in a
  # Bootstrap grid column.
  def select(method, choices = nil, options = {}, html_options = {}, &block)
    process_options(method, options)
    process_width(options) { super }
  end

  ##
  # Static control
  # If column_width: n or :col_width: n is given as an option, wrap in a
  # Bootstrap grid column.
  # If `lstrip: string` is given as an option, strip the string from the
  # left side of the label.
  # Set the placeholder to the label, unless :placeholder is given in the
  # options.
  def static_control(method, options = {})
    options = process_options(method, options)
    process_width(options) { super }
  end

  ##
  # Format a text area
  def text_area(method, options = {})
    options = process_options(method, options)
    process_width(options) { super }
  end

  ##
  # Format a text field
  def text_field(method, options = {})
    options = process_options(method, options)
    process_width(options) { super }
  end

  private

  def format_label(field, options = {})
    label = field.class == String ? field : field.to_s.titlecase
    label = label.sub(/\A#{options[:lstrip]}\s*/, "") if options[:lstrip]
    label
  end

  def process_options(method, options = {})
    label_modifier = options.delete(:lstrip)
    options[:label] ||= format_label(method, lstrip: label_modifier)
    options[:placeholder] ||= options[:label]
    options
  end

  ##
  # Ugh. This modifies the options, which might not be usable in many
  # cases.
  def process_width(options = {})
    width = (options.delete(:column_width) || options.delete(:col_width))

    if width
      content_tag :div, yield, class: "col-sm-#{width}"
    else
      yield
    end
  end
end
