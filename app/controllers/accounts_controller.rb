##
# Manage accounts.
class AccountsController < ApplicationController
  skip_before_action :account_exists!, only: [:create, :index, :new]

  def create
    @account = Account.new(account_params)
    if @account.save
      current_user.account = @account
      if current_user.save
        redirect_to user_root_url
        return
      end
    end

    logger.warn @account.errors.full_messages
    render :new
  end

  def destroy
    @account = current_account
    save_account(active: false)
  end

  def edit
    @account = current_account
  end

  def new
    @account = Account.new
  end

  def update
    @account = current_account
    save_account(account_params)
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end

  def save_account(params)
    if @account.update(params)
      redirect_to user_root_url
    else
      logger.warn @account.errors.full_messages
      render :edit
    end
  end
end
