require "test_helper"

class CiTest < ActiveSupport::TestCase
  test "validate presence of active" do
    ci = Ci.new # (account: accounts(:company_a))
    assert_not ci.valid?, "Valid when it should be invalid."
    assert_equal [
      "Account must exist" # ,
      # "Active can't be blank" Default scope means this doesn't happen.
    ], ci.errors.full_messages
  end

  test "available_for_parents includes grandparent" do
    assert @ci.available_for_parents.to_a.include?(@grandparent)
  end

  test "available_for_parents doesn't include parent" do
    assert_not @ci.available_for_parents.to_a.include?(@parent)
  end

  test "available_for_parents doesn't include child" do
    assert_not @ci.available_for_parents.to_a.include?(@child)
  end

  test "available_for_parents doesn't include grandchild" do
    assert_not @ci.available_for_parents.to_a.include?(@grandchild)
  end

  test "available_for_parents doesn't include self" do
    assert_not @ci.available_for_parents.to_a.include?(@ci)
  end

  test "available_for_parents includes unrelated" do
    assert @ci.available_for_parents.to_a.include?(@unrelated)
  end

  def setup
    @account = Account.new(name: "No CIs")
    @ci = Ci.create(account: @account, name: "Me")
    # Just to keep us honest, put in a CI for another account
    Ci.create(account: accounts(:company_a), name: "Other company")
    @unrelated = Ci.create(account: @account, name: "Unrelated")
    @parent = @ci.parents.create(account: @account, name: "Parent")
    @grandparent =
      @parent.parents.create(account: @account, name: "Grandparent")
    @child = @ci.children.create(account: @account, name: "Child")
    @grandchild = @child.children.create(account: @account, name: "Grandchild")
  end
end
