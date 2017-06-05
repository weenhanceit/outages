class CisController < ApplicationController
  include TestSuite
  def show
    @ci = ci_list[params[:id].to_i]
  end

  def update
    # TODO: Where do we go from here?
    redirect_to edit_ci_path(params[:id]), alert: "I don't know where I should go."
  end

  def destroy
    redirect_to cis_path
  end
end
