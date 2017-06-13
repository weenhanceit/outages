class CisController < ApplicationController
  include TestSuite

  def create
    @ci = Ci.new(ci_params)
    @ci.account = current_user.account
    if @ci.save
      redirect_to cis_path
    else
      logger.warn @ci.errors.full_messages
      render :new
    end
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

# TODO: Does Rails have a better way to handle model defaults?
def ci_defaults
  {
    active: true
  }
end

def ci_params
  params.require(:ci).permit(:id,
    :account_id,
    :active,
    :description,
    :name,
    :maximum_unavailable_children_with_service_maintained,
    :minimum_children_to_maintain_service)
end
