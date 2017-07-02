module OutagesHelper
  ##
  # Default earliest time for outages filtering.
  def default_earliest
    Time.zone.now.beginning_of_day
  end

  ##
  # Default latest time for outages filtering.
  def default_latest
    default_earliest + 2.weeks
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
end
