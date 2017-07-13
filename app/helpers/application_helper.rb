module ApplicationHelper
  def notes_sort_order
    params.fetch(:sort_order, session.fetch(:sort_order, "desc"))
  end
end
