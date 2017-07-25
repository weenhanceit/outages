module OutagesHelper
  ##
  # Default earliest time for outages filtering.
  def default_earliest
    Time.zone.now.beginning_of_day
  end

  ##
  # Default latest time for outages filtering.
  def default_latest(earliest = default_earliest)
    earliest + 2.weeks
  end

  ##
  # Format the calendar view content for an outage, when there is little room
  # for the outage.
  def brief_calendar_outage(outage, date)
    link_to(outage.name, edit_or_show_outage_path(outage))
  end

  ##
  # Format the calendar view content for an outage, when the calendar view
  # can show more detail, e.g. the day, four-day, and week views.
  def detailed_calendar_outage(outage, date)
    "".html_safe +
      outage.start_time_on_date(date).to_s(:hms) +
      " to " +
      outage.end_time_on_date(date).to_s(:hms) +
      " " +
      link_to(outage.name, edit_or_show_outage_path(outage))
  end

  ##
  # True when the user wants to get completed outages too.
  # TODO: Duplicated code between user.rb and here.
  def get_completed_too?
    session.fetch(:completed, params.fetch(:completed, "0")) == "1"
  end

  ##
  # For grid view when it's by itself, default to showing only two weeks.
  def outages_before
    # puts "outages_before: #{params.fetch(:latest, session.fetch(:latest, default_latest.to_s(:browser)))}"
    # puts "params[:latest]: #{params[:latest]}" if params[:latest].present?
    # puts "session[:latest]: #{session[:latest]}" if session[:latest].present?
    # puts "default_latest.to_s(:browser): #{default_latest.to_s(:browser)}"
    params.fetch(:latest, session.fetch(:latest, default_latest.to_s(:browser)))
  end

  ##
  # Get the last used search string for outages.
  def search_string
    params.fetch(:frag, session[:frag])
  end

  ##
  # The label and value when the user wants only the outages that interest them
  def of_interest
    "Of interest to me"
  end

  ##
  # Is the user requesting only outages of interest?
  # If neight params nor session are set, then this is true.
  def of_interest?
    of_interest == params.fetch(:watching,
                    session.fetch(:watching,
                      of_interest))
  end

  ##
  # Provide a start date for the calendar views based on the params.
  # When this is called, at least one of start_date, earliest, or latest
  # must be present.
  def start_date
    if params[:start_date].present?
      Time.zone.parse(params[:start_date])
    elsif params[:earliest].present?
      Time.zone.parse(params[:earliest])
    else
      Time.zone.parse(params[:latest])
    end
  end
end
