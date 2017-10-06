# frozen_string_literal: true
class NotificationChannel < ApplicationCable::Channel
  def broadcast_to(model, message)
    message = ApplicationController.render_to_string(partial: "notification", object: notification)
    puts "Broadcasting #{message}"
    super
  end

  def subscribed
    # stream_from "some_channel"
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
