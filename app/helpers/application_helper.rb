module ApplicationHelper
  def home_link
    link_to current_account&.name || "Outage Master",
      root_path,
      class: "navbar-brand"
  end

  def notes_sort_order
    params.fetch(:sort_order, session.fetch(:sort_order, "desc"))
  end
end
