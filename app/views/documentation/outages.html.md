# Outages

Outages are the core of this application.
Typically, outages are scheduled by the person who has to do the work,
in other words,
the technical folks.
An outage is pretty simple:
It has a start and end date and time,
and indicates which service or services
will be unavailable during the work.
Of course,
it's generally helpful to provide a name
and description for the outage as well.

Go to the
<%= link_to_if_logged_in "Outages", outages_path %>
page
and click on the "Add Outage" button.
