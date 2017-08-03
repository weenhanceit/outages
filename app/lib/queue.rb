# TODO: Move this documentation to somewhere permanent.
##
# Handle actions that may have to take place in the future
# Here's what has to take place at a specific time in the future:
#
# * Reminders before start of outage (start time and user preference)
# * Notifications of overdue outages (end time)
# * Send a user's batched e-mail
#
# Here's a list of stuff we have to do. Is this complete:
#
# <table>
# <thead>
# <tr>
# <td>Condition</td><td>Actions</td>
# </tr>
# </thead>
# <tbody>
# <tr>
# <td>New outage</td>
# <td>
# Tell all users who are watching the outage and want to know about changes
# </td>
# </tr>
# <tr>
# <td>Change start time</td>
# <td>
# * Tell all users who are watching the outage and want to know about changes
# * Change all future reminder events for the outage
# </td>
# </tr>
# <tr>
# <td>Change end time</td>
# <td>
# * Tell all users who are watching the outage and want to know about changes
# * Change all future "check for overdue" events
# </td>
# </tr>
# <tr>
# <td>Add, modify, delete note</td>
# <td>
# Tell all users watching the outage who want to know about notes
# </td>
# </tr>
# <tr>
# <td>Outage complete</td>
# <td>
# * Tell all users who are watching the outage and want to know about completion
# * Cancel the outage overdue event
# </td>
# </tr>
# <tr>
# <td>Stop getting batched e-mail</td>
# <td>
# Cancel the next batch e-mail event for user.
# Send out e-mails for outstanding e-mail notifications.
# </td>
# </tr>
# <tr>
# <td>Start getting batched e-mail</td>
# <td>
# Set up a batch e-mail event for user
# </td>
# </tr>
# <tr>
# <td>Stop watching overdue outages</td>
# <td>
# User gets no more overdue notifications
# </td>
# </tr>
# <tr>
# <td>Start watching overdue outages</td>
# <td>
# Add a overdue event for all pending, uncompleted, watched outages
# </td>
# </tr>
# <tr>
# <td>Stop getting e-mail notifications</td>
# <td>
# Destroy all pending e-mail notifications
# </td>
# </tr>
# <tr>
# <td>Start getting e-mail notification</td>
# <td>
# Generate e-mail notifications for pending events --
# actually probably not needed given that the event drives the notifications.
# </td>
# </tr>
# <tr>
# <td>Stop getting reminders</td>
# <td>
# Cancel the user's reminder events
# </td>
# </tr>
# <tr>
# <td>Start getting reminders</td>
# <td>
# Add a reminder event for all pending, uncompleted, watched outages
# </td>
# </tr>
# <tr>
# <td>Delete a CI relationship</td>
# <td>
# You would have to know how to identify all the notifications
# that happened because of the DAG.
# You could find all the connected nodes to the removed edge,
# </td>
# </tr>
# </tbody>
# </table>
#
# module Queue
#   ##
#   # Add an action to the queue.
#   def self.enqueue(action_time = Time.zone.now, params = {})
#     Queue.transaction do
#       Queue.create!(params)
#       if action_time < next_queue_action.Time
#         # Set a job to start at action_time
#         QueueJob.set(wait_until: action_time).perform_later
#         # Optimization to check if there is already something set to run then.
#         # Isn't that optimization done already by checking strictly less than?
#       end
#     end
#   end
#
#   ##
#   # Process all items on the queue that were scheduled to be run by now.
#   def self.dequeue
#     done = []
#     Queue.transaction do
#       Queue.where("time <= ?", Time.zone.now) do |action|
#         # ...
#         done << action.destroy
#       end
#     end
#     # TODO: Now add the next job.
#     # If this is outside the transaction, if the server crashes we don't
#     # have another dequeue scheduled.
#     done
#   end
#
#   private
#
#   ##
#   # Get the first  tiem on the queue, aka the next item to be done.
#   def first_queue_action
#     Queue.order(:time).first
#   end
#
#   alias next_queue_action first_queue_action
# end
