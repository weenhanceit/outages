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

  test "available_for_parents on new includes all" do
    ci = Ci.new(account: @account)
    assert_equal ci.available_for_parents.to_a.sort,
      [@grandparent, @parent, @ci, @child, @grandchild, @unrelated].sort
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

  test "available_for_children on new includes all" do
    ci = Ci.new(account: @account)
    assert_equal ci.available_for_children.to_a.sort,
    [@grandparent, @parent, @ci, @child, @grandchild, @unrelated].sort
  end

  test "available_for_children doesn't include grandparent" do
    assert_not @ci.available_for_children.to_a.include?(@grandparent)
  end

  test "available_for_children doesn't include parent" do
    assert_not @ci.available_for_children.to_a.include?(@parent)
  end

  test "available_for_children doesn't include child" do
    assert_not @ci.available_for_children.to_a.include?(@child)
  end

  test "available_for_children includes grandchild" do
    assert @ci.available_for_children.to_a.include?(@grandchild)
  end

  test "available_for_children doesn't include self" do
    assert_not @ci.available_for_children.to_a.include?(@ci)
  end

  test "available_for_children includes unrelated" do
    assert @ci.available_for_children.to_a.include?(@unrelated)
  end

  def setup
    @account = Account.new(name: "No CIs")
    @ci = Ci.create(account: @account, name: "Me")
    @unrelated = Ci.create(account: @account, name: "Unrelated")
    @parent = @ci.parents.create(account: @account, name: "Parent")
    @grandparent =
      @parent.parents.create(account: @account, name: "Grandparent")
    @child = @ci.children.create(account: @account, name: "Child")
    @grandchild = @child.children.create(account: @account, name: "Grandchild")
  end
end
