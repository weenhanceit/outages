module CisHelper
  ##
  # Get the last used search string for CIs.
  def cis_search_string
    params.fetch(:text, session[:cis_text])
  end

  ##
  # The label and value when the user wants only the CIs that interest them
  def cis_of_interest
    "Of interest to me"
  end

  ##
  # Is the user requesting only CIs of interest?
  # If neither params nor session are set, then this is false (i.e. see all).
  def cis_of_interest?
    cis_of_interest == params.fetch(:cis_watching,
      session.fetch(:cis_watching, "All"))
  end
end
