##
# Manage accounts.
class AccountsController < ApplicationController
  skip_before_action :account_exists!, only: [:create, :index, :new]
end
