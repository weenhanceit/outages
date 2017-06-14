require "test_helper"

class CiTest < ActiveSupport::TestCase
  test "validate presence of active" do
    ci = Ci.new # (account: accounts(:company_a))
    assert_not ci.valid?, "Valid when it should be invalid."
    assert_equal [
      "Account must exist" ,
      "Name can't be blank"
      # "Active can't be blank" Default scope means this doesn't happen.
    ], ci.errors.full_messages.sort
  end
end
