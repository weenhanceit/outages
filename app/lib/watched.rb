module Watched
  def update_watches(user, active)
    watch = watches.find_by(user: user)

    if !active
      # puts "Remove watch" if watch
      watch.update_attribute(:active, false) if watch
    elsif watch
      watch.update_attribute(:active, true)
      # puts "Set watch, watches: #{@outage.watches.inspect}"
    else
      # The usual Rails dance: set both sides of the association so the
      # autosave will work.
      watch = watches.build(user: user)
      watch.watched = self
      # puts "Created watch, watches: #{@outage.watches.inspect}"
    end
    # puts "update_watches watches.size after: #{watches.size}"
  end

  ##
  # Indicates if the watched item is being watch by the user referenced in
  # the last call to `#watched_by`. This little hack is to make things work
  # in the view.
  def watched
    @watched
  end

  ##
  # Checked if the user is watching this watched item.
  def watched_by(user)
    @watched = watches.where(user: user).present?
  end
end
