# frozen_string_literal: true
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_authenticated_user
    end

    private

    def find_authenticated_user
      # puts "find_authenticated_user: #{env['warden'].user}"
      if current_user = env["warden"].user # rubocop:disable Lint/AssignmentInCondition
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
