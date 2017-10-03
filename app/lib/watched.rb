##
# Common code for anything that can be watched.
module Watched
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
    watches.unscope(where: :active).find_by(user: user)
  end

  ##
  # Return the watch for the object, or a new watch if none found. The new
  # watch should be active if the object is new, correspoding to the watch
  # being on by default when the user creates a new CI or Outage.
  def watched_by_or_new(user)
    watched_by(user) || watches.build(user: user, active: !persisted?)
  end
end
