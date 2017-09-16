# Services

"Services" in Outages are information technology assets,
in the broadest sense of assets.
Therefore,
a service can be an individual server,
a network router,
a URL,
a software service like an application,
etc.
One of the features of Outages
is that a service can really be anything you need it to be.

In any modern IT shop,
all services that an end user cares about
are composed of many other services.
Often,
when one of the lower-level services is unavailable,
one or more services that depend on that service
are also unavailable.
Outages tracks the relationships between services,
so it knows when unavailability of one service
causes other services to be unavailable.

End users are interested in services that represent the high-level,
business oriented functions.

Typically
the more technically-oriented people
in an organization
identify the services
and the relationships between them.
(And because of that, the rest of this page gets a bit technical.)

A simplified example of some services and their relationships is:

* Various people in an organization use the ACME Sales Application,
so it's a service
* The ACME Sales Application is a modern web application,
so it includes a cluster of servers. The cluster itself is a service
* Each server is the cluster is an individual service
* The cluster also depends on a load balancer.
The load balancer is a service
* The sales application depends on a database.
The database is another service

To set up a service,
got to the
<%= link_to_if_logged_in "Services", cis_path %>
page,
and click on the "Add Service" button.

(If you're into that whole ITSM/ITIL thing,
a service is a configuration item (CI).
And Outages includes a simple
configuration management database (CMDB).
But we try not to force you to learn some lingo
if you don't want to.)
