# Introduction

Outages is an application
meant to help IT departments and users
communicate planned outages of services.

Most organizations communicate planned service outages
in two ways:

* E-mails to everyone for every outage,
leading to a full inbox, and meesages that are ignored
* Posting them on a web site that no one remembers to look at

Outages aims to solve the problem
by giving the recipient control
over the type of notifications they receive
and the services for which they receive notifications.
Typically, you're only interested in certain services:

* An end user only cares about production systems
* An end user may only care about certain prodution systems,
because their job is focussed on that application
* A developer may not care about production systems,
and only cares about the development environments
that they directly work on
* An operational support person will care about their
particular piece of the infrastructure,
across all development, test, and production environments

Here's what has to happen to get the benefits of Outages:

* Technical staff enter services,
and identify the relationships between the services.
A service can be anything from a single piece of IT equipment,
all the way up to a complete application.
The relationships show dependencies
between the services.
For example, an application is made up of other hardware and software services,
each of which may be made up of other services,
and so on.
<%= link_to "Services", documentation_services_path %>
* Technical staff (typically) enter outages -- times when
they're going to be working on a service,
and the service will be unavailable.
<%= link_to "Outages", documentation_outages_path %>
* Everyone who wants to be notified of outages
has to set up their preferences
to indicate how and when they want to be notified of outages.
They also have to indicate what they're watching.
Most of the time users watch a service,
and get notified about outages of that service.
You can also watch an outage.
<%= link_to "Watches", documentation_watches_path %>

However, the very first thing someone has to do
is
<%= link_to "set up an account", documentation_set_up_account_path %>
for your organization
