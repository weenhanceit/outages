module CisHelper
  ##
  # Get the last used search string for outages.
  def cis_search_string
    params.fetch(:text, session[:cis_text])
  end
end
