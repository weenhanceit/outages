# frozen_string_literal: true
class CisController < ApplicationController
  include TestSuite

  def create
    # The following commented-out lines didn't work, but I think they should.
    # I fear it's a problem with associations again.
    # @ci = Ci.new(ci_params)
    # @ci.account = current_user.account
    # puts params.inspect
    @ci = Ci.new(ci_params_without_dag)
    @ci.account = current_user.account
    update_watches

    if @ci.save
      # puts @ci.watches.inspect
      # puts ci_dag_params.inspect
      if @ci.update(ci_dag_params)
        redirect_to cis_path
        return
      end
    end

    puts "SAVE FAILED"
    logger.warn @ci.errors.full_messages
    online_notifications
    render :new
  end

  def destroy
    @ci = current_user.account.cis.find_by(id: params[:id])
    @ci.active = false
    if @ci.save
      redirect_to cis_path
    else
      logger.warn @ci.errors.full_messages
      online_notifications
      render :edit
    end
  end

  def edit
    not_found unless current_user.can_edit_cis?
    # puts "IN EDI"
    @ci = current_user.account.cis.find_by(id: params[:id])
    # Put in an Array even though there's only one, to trick Rails into generating the right view
    @watched = [@ci.watched_by_or_new(current_user)]
  end

  def index
    # puts "INDEX PARAMS: #{params.inspect}"
    session[:cis_watching] = params[:cis_watching] if params[:cis_watching].present?
    # if session[:cis_watching].present? && session[:cis_watching] == "Of interest to me"
    @cis = if helpers.cis_of_interest?
             # puts "CIs watching: #{session[:cis_watching]}"
             current_user.cis
           # puts "FOUND WATCHED CIS: #{@cis.inspect}"
           else
             current_account.cis.where(active: true)
           end
    session[:cis_text] = params[:text] if params[:text]
    if session[:cis_text].present?
      # puts "CIs only: #{session[:cis_text]}"
      @cis = @cis.where("lower(name) like ?", "%#{session[:cis_text].downcase}%")
    end
    # puts "CIS.COUNT #{@cis.count}"
    @cis = @cis.order(:name)
    # puts render_to_string(partial: "cis")
  end

  def new
    @ci = Ci.new(ci_defaults)
    # Put in an Array even though there's only one, to trick Rails into generating the right view
    @watched = [@ci.watched_by_or_new(current_user)]
    # puts "@watched: #{@watched.inspect}"
  end

  def show
    @notable = @ci = current_user.account.cis.find_by(id: params[:id])
    session[:sort_order] = params[:sort_order] if params[:sort_order].present?
  end

  def update
    @ci = current_user.account.cis.find_by(id: params[:id])
    update_watches
    #  TODO: This was a test that I was trying to create a save error.  But the
    # ci was saved with a null account id
    # @ci.account_id = nil
    # phil = "Name: #{@ci.name} Valid: #{@ci.valid?} AccountID: #{@ci.account_id}"
    # render plain: phil
    if @ci.update(ci_params)
      redirect_to cis_path
    else
      puts "SAVE FAILED"
      logger.warn @ci.errors.full_messages
      online_notifications
      render :edit
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
              available_for_children_attributes: [:child_id, :_destroy],
              watches_attributes: [
                :id,
                :watched_type,
                :watched_id,
                :user_id,
                :active
              ])
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
      available_for_children_attributes: [:child_id, :_destroy],
      watches_attributes: [
        :id,
        :watched_type,
        :watched_id,
        :user_id,
        :active
      ])
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

  def update_watches
    @ci.update_watches(current_user, params[:ci][:watched].in?(%w(1 true)))
  end
end
