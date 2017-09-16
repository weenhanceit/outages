##
# Display documentation pages.
# A separate controller to facilitate access control,
# and default layout.
class DocumentationController < ApplicationController
  skip_before_action :authenticate_user!
end
