class CisController < ApplicationController
  include TestSuite

  def create
    # The following commented-out lines didn't work, but I think they should.
    # I fear it's a problem with associations again.
    # @ci = Ci.new(ci_params)
    # @ci.account = current_user.account
    @ci = Ci.new(ci_params_without_dag)
    @ci.account = current_user.account

    if @ci.save
      if @ci.update(ci_dag_params)
        redirect_to cis_path
        return
      end
    end

    logger.warn @ci.errors.full_messages
    render :new
  end

  def destroy
    @ci = current_user.account.cis.find_by(id: params[:id])
    @ci.active = false
    if @ci.save
      redirect_to cis_path
    else
      logger.warn @ci.errors.full_messages
      render :edit
    end
  end

  def edit
    # puts "IN EDI"
    @ci = current_user.account.cis.find_by(id: params[:id])
  end

  def index
    @cis = current_user.account.cis.where(active: true).order(:name)
  end

  def new
    @ci = Ci.new(ci_defaults)
  end

  def show
    @ci = ci_list[params[:id].to_i]
  end

  def update
    @ci = current_user.account.cis.find_by(id: params[:id])
    #  TODO This was a test that I was trying to create a save error.  But the
    # ci was saved with a null account id
    # @ci.account_id = nil
    # phil = "Name: #{@ci.name} Valid: #{@ci.valid?} AccountID: #{@ci.account_id}"
    # render plain: phil
    if @ci.update(ci_params)
      redirect_to cis_path
    else
      logger.warn @ci.errors.full_messages
      render :edit
    end
  end
end

private

# Some sources say the best way to do model defaults is in an
# `after_initialize` callback. The approach below works as a way of
# defaulting in the UI, but not making any preconceived notions about
# the model itself.
def ci_defaults
  {
    active: true,
    account: current_account
  }
end

def ci_dag_params
  params
    .require(:ci)
    .permit(parent_links_attributes: [:child_id, :id, :parent_id, :_destroy],
      available_for_parents_attributes: [:parent_id, :_destroy],
      child_links_attributes: [:child_id, :id, :parent_id, :_destroy],
      available_for_children_attributes: [:child_id, :_destroy])
end

def ci_params
  params.require(:ci).permit(:id,
    :account_id,
    :active,
    :description,
    :name,
    :maximum_unavailable_children_with_service_maintained,
    :minimum_children_to_maintain_service,
    parent_links_attributes: [:child_id, :id, :parent_id, :_destroy],
    available_for_parents_attributes: [:parent_id, :_destroy],
    child_links_attributes: [:child_id, :id, :parent_id, :_destroy],
    available_for_children_attributes: [:child_id, :_destroy])
end

def ci_params_without_dag
  params.require(:ci).permit(:id,
    :account_id,
    :active,
    :description,
    :name,
    :maximum_unavailable_children_with_service_maintained,
    :minimum_children_to_maintain_service)
end
