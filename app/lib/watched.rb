module Watched
  def update_watches(user, active)
    watch = watches.unscope(where: :active).find_by(user: user)

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
  # Indicates if the watched item is being watched by the user referenced in
  # the last call to `#watched_by`. This little hack is to make things work
  # in the view.
  def watched
    !!@watched
  end

  ##
  # Checked if the user is watching this watched item.
  def watched_by(user)
    @watched = watches.unscope(where: :active).find_by(user: user)
  end

  ##
  # Return the watch for the object, or a new watch if none found. The new
  # watch should be active if the object is new, correspoding to the watch
  # being on by default when the user creates a new CI or Outage.
  def watched_by_or_new(user)
    watched_by(user) || watches.build(user: user, active: !persisted?)
  end
end
